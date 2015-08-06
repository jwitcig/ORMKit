//
//  ORCloudData.swift
//  ORMKit
//
//  Created by Developer on 6/18/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORCloudData: DataConvenience {
    
    var dataManager: ORDataManager
    
    var session: ORSession
    
    var container: CKContainer {
        get { return self.dataManager.cloudDataCoordinator.container }
    }
    public var database: CKDatabase {
        get { return self.dataManager.cloudDataCoordinator.database }
    }
    
    public var syncInProgress: Bool = false
    
    public required init(session: ORSession, dataManager: ORDataManager) {
        self.session = session
        self.dataManager = dataManager
    }
    
    public func fetchAllOrganizations(options options: ORDataOperationOptions? = nil, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: OROrganization.self,
                                predicate: NSPredicate.allRows,
                                  options: options,
                        completionHandler: completionHandler)
    }
    
    public func fetchAssociatedOrganizations(athlete unsafeAthlete: ORAthlete, completionHandler: ((ORCloudDataResponse)->())?) {
        let context = NSManagedObjectContext.contextForCurrentThread()
        
        let athlete = context.objectWithID(unsafeAthlete.objectID) as! ORAthlete
        
        let predicate = NSPredicate(key: "athletes", comparator: .Contains, value: athlete.reference)
        
        self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) {
            let athlete = $0.currentThreadContext.objectWithID(unsafeAthlete.objectID) as! ORAthlete

            var compoundResults = $0.objects
        
            let predicate = NSPredicate(key: "admins", comparator: .Contains, value: athlete.reference)
            self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) {
                let recordNames: [String] = compoundResults.recordIDs.recordNames
                compoundResults += $0.objects.filter {
                    !recordNames.contains($0.recordID.recordName)
                }
                
                completionHandler?(ORCloudDataResponse(
                                                request: $0.request,
                                                object: OROrganization.self,
                                               objects: compoundResults,
                                                 error: $0.error))
            }
        }
    }
    
    public func fetchLiftTemplates(session session: ORSession, completionHandler: ((ORCloudDataResponse)->())?) {
        guard let organization = session.currentOrganization else {
            completionHandler?(ORCloudDataResponse(request: ORCloudDataRequest(), error: ORDataTools.currentOrganizationMissingError))
            return
        }
                
        if session.soloSession {

        } else {
            self.fetchLiftTemplates(organizations: [organization], completionHandler: completionHandler)
        }
    }
    
    public func fetchLiftTemplates(organizations organizations: [OROrganization], completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORLiftTemplate.self,
                                predicate: NSPredicate(key: "organization", comparator: .In, value: organizations.references),
                        completionHandler: completionHandler)
    }

    public func fetchLiftEntries(template template: ORLiftTemplate, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORLiftEntry.self,
                                predicate: NSPredicate(key: "liftTemplate", comparator: .Equals, value: template.reference),
                        completionHandler: completionHandler)
    }
    
    public func fetchLiftEntries(templates templates: [ORLiftTemplate], completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORLiftEntry.self,
                                predicate: NSPredicate(key: "liftTemplate", comparator: .In, value: templates.references),
                        completionHandler: completionHandler)
    }
    
    public func fetchMessages(organization organization: OROrganization, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORMessage.self,
                                predicate: NSPredicate(key: "organization", comparator: .Equals, value: organization.reference),
                        completionHandler: completionHandler)
    }
    
    public func save(model model: ORModel, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.saveCloud(record: model.record, completionHandler: completionHandler)
    }
    
    public func fetchAthletes(organization organization: OROrganization, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORAthlete.self,
                                predicate: NSPredicate.allRows,
                        completionHandler: completionHandler)
    }
    
    public func syncronizeDataToLocalStore(completionHandler: ((ORCloudDataResponse)->())? = nil) -> Bool {
        guard !self.syncInProgress else {
            print("sync in progress")
            return false
        }
        self.syncInProgress = true
        
        self.fetchAssociatedOrganizations(athlete: self.session.currentAthlete!) {
            guard $0.success else { return }
                        
            let organizations = OROrganization.organizations(records: $0.objects, context: $0.context)
            self.session.localData.save(context: $0.context)
            
            self.fetchLiftTemplates(organizations: organizations) {
                guard $0.success else { return }

                let templates = ORLiftTemplate.templates(records: $0.objects, context: $0.context)
                self.session.localData.save(context: $0.context)
                
                self.fetchLiftEntries(templates: templates) {
                    guard $0.success else { return }
                    ORLiftEntry.entries(records: $0.objects, context: $0.context)
                    self.session.localData.save(context: $0.context)
                    completionHandler?($0)
                    
                    self.syncInProgress = false
                }
            }
        }
        return true
    }
    
    public func syncronizeDataToCloudStore(perRecordCompletionHandler perRecordCompletionHandler: ((ORCloudDataResponse)->())? = nil, completionHandler: ((ORCloudDataResponse)->())? = nil) -> Bool {
        guard !self.syncInProgress else {
            print("sync in progress")
            return false
        }
        
        let request = ORCloudDataRequest()
        self.syncInProgress = true
        
        let dirtyFetchResponse = self.session.localData.fetchDirtyObjects(model: ORModel.self)
        guard dirtyFetchResponse.success else { return true }
        
        let recordsToSave = dirtyFetchResponse.objects.records
        let deletedObjectIDs = self.session.localData.fetchDeletedIDs().dataObjects as? [CKRecordID]
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: deletedObjectIDs)
        
        operation.perRecordCompletionBlock = { completedRecord, error in
            guard error == nil else { return }
            guard let record = completedRecord else { return }
            
            let context = NSManagedObjectContext.contextForCurrentThread()
            let model = ORModel.model(type: ORModel.self, record: record, context: context)
            model.cloudRecordDirty = false
            
            self.session.localData.save(context: context)
            perRecordCompletionHandler?(ORCloudDataResponse(request: request, object: record, error: error, context: context))
        }
        
        operation.modifyRecordsCompletionBlock = { attemptedSaveRecords, attemptedDeleteRecordIDs, error in
            
            completionHandler?(ORCloudDataResponse(request: request, error: error))
            self.syncInProgress = false
            
            let context = NSManagedObjectContext.contextForCurrentThread()

            if let deletedIDs = deletedObjectIDs {
                let deletedObjectsRecords = self.session.localData.fetchCloudRecords([NSPredicate(key: "recordName", comparator: .In, value: deletedIDs.recordNames)], context: context)
                self.session.localData.delete(objects: deletedObjectsRecords, context: context)
            }
        }
                                                
        self.database.addOperation(operation)
        return true
    }
    
}
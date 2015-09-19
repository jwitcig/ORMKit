//
//  ORCloudData.swift
//  ORMKit
//
//  Created by Developer on 6/18/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif
import CloudKit
import CoreData

public class ORCloudData: DataConvenience {
    
    var dataManager: ORDataManager
    
    var session: ORSession
    
    var container: CKContainer {
        return self.dataManager.cloudDataCoordinator.container
    }
    public var database: CKDatabase {
        return self.dataManager.cloudDataCoordinator.database
    }
    
    public var syncInProgress: Bool = false
    
    public required init(session: ORSession, dataManager: ORDataManager) {
        self.session = session
        self.dataManager = dataManager
    }
    
    public func fetchAllOrganizations(options options: ORDataOperationOptions? = nil, completionHandler: (([OROrganization], ORCloudDataResponse)->())?) {
        
        self.dataManager.fetchCloud(model: OROrganization.self,
                                predicate: NSPredicate.allRows,
                                  options: options,
                        completionHandler: completionHandler)
    }
    
    public func fetchAssociatedOrganizations(athlete unsafeAthlete: ORAthlete, completionHandler: (([OROrganization], ORCloudDataResponse)->())?) {
        let context = NSManagedObjectContext.contextForCurrentThread()
        
        let athlete = context.crossContextEquivalent(object: unsafeAthlete)
        
        let predicate = NSPredicate(key: "athletes", comparator: .Contains, value: athlete.reference)
        
        self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) {
            let athlete = $1.currentThreadContext.crossContextEquivalent(object: unsafeAthlete)

            guard var compoundResults = $1.records else { return }
            
            let predicate = NSPredicate(key: "admins", comparator: .Contains, value: athlete.reference)
            self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) { (organizations, response) in
                
                guard let organizationRecords = response.records else { return }
                
                let recordNames: [String] = compoundResults.recordIDs.recordNames
                compoundResults += organizationRecords.filter {
                    !recordNames.contains($0.recordID.recordName)
                }
                
                let organizations = OROrganization.organizations(records: compoundResults, context: response.currentThreadContext)
                
                completionHandler?(organizations, ORCloudDataResponse(
                                                request: response.request,
                                                 error: response.error))
            }
        }
    }
    
    public func fetchLiftTemplates(session session: ORSession, completionHandler: (([ORLiftTemplate], ORCloudDataResponse)->())?) {
        guard let organization = session.currentOrganization else {
            completionHandler?([], ORCloudDataResponse(request: ORCloudDataRequest(), error: ORDataTools.currentOrganizationMissingError))
            return
        }
                
        if session.soloSession {

        } else {
            self.fetchLiftTemplates(organizations: [organization], completionHandler: completionHandler)
        }
    }
    
    public func fetchLiftTemplates(organizations organizations: [OROrganization], completionHandler: (([ORLiftTemplate], ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORLiftTemplate.self,
                                predicate: NSPredicate(key: "organization", comparator: .In, value: organizations.references),
                        completionHandler: completionHandler)
    }

    public func fetchLiftEntries(template template: ORLiftTemplate, completionHandler: (([ORLiftEntry], ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORLiftEntry.self,
                                predicate: NSPredicate(key: "liftTemplate", comparator: .Equals, value: template.reference),
                        completionHandler: completionHandler)
    }
    
    public func fetchLiftEntries(templates templates: [ORLiftTemplate], completionHandler: (([ORLiftEntry], ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORLiftEntry.self,
                                predicate: NSPredicate(key: "liftTemplate", comparator: .In, value: templates.references),
                        completionHandler: completionHandler)
    }
    
    public func fetchMessages(organization organization: OROrganization, completionHandler: (([ORMessage], ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORMessage.self,
                                predicate: NSPredicate(key: "organization", comparator: .Equals, value: organization.reference),
                        completionHandler: completionHandler)
    }
    
    public func save(model model: ORModel, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.saveCloud(record: model.record, completionHandler: completionHandler)
    }
    
    public func fetchAthletes(organization organization: OROrganization, completionHandler: (([ORAthlete], ORCloudDataResponse)->())?) {
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
        
        self.fetchAssociatedOrganizations(athlete: self.session.currentAthlete!) { (organizations, response) in
            guard response.success else {
                self.syncInProgress = false
                return
            }
            
            self.session.localData.save(context: response.currentThreadContext)
            
            self.fetchLiftTemplates(organizations: organizations) { (liftTemplates, response) in
                guard response.success else {
                    self.syncInProgress = false
                    return
                }
                
//                let (abandonedTemplates, response) = self.session.localData.fetchAbandonedRecords(cloudModels: liftTemplates, context: response.currentThreadContext)
//                abandonedTemplates.map(response.currentThreadContext.deleteObject)
                
                self.session.localData.save(context: response.currentThreadContext)
                
                self.fetchLiftEntries(templates: liftTemplates) { (liftEntries, response) in
                    guard response.success else {
                        self.syncInProgress = false
                        return
                    }
                    
                    
                    let (abandonedEntries, _) = self.session.localData.fetchAbandonedRecords(cloudModels: liftEntries, context: response.currentThreadContext)
                    abandonedEntries.map(response.currentThreadContext.deleteObject)
                    
                    self.session.localData.save(context: response.currentThreadContext)
                    
                    self.syncInProgress = false
                    completionHandler?(response)
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
        
        let (dirtyObjects, dirtyFetchResponse) = self.session.localData.fetchDirtyObjects(model: ORModel.self)
        guard dirtyFetchResponse.success else { return true }
        
        let recordsToSave = dirtyObjects
        let (deletedObjectIDs, _) = self.session.localData.fetchDeletedIDs()
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave.records, recordIDsToDelete: deletedObjectIDs)
        
        operation.perRecordCompletionBlock = { completedRecord, error in
            guard error == nil else { print(completedRecord); return }
            guard let record = completedRecord else { return }
            
            let context = NSManagedObjectContext.contextForCurrentThread()
            let model = ORModel.model(type: ORModel.self, record: record, context: context)
            model.cloudRecordDirty = false
            
            self.session.localData.save(context: context)
            perRecordCompletionHandler?(ORCloudDataResponse(request: request, error: error, context: context))
        }
        
        operation.modifyRecordsCompletionBlock = { attemptedSaveRecords, attemptedDeleteRecordIDs, error in
            self.syncInProgress = false
            
            completionHandler?(ORCloudDataResponse(request: request, error: error))
            
            let context = NSManagedObjectContext.contextForCurrentThread()

            let (deletedObjectsRecords, _) = self.session.localData.fetchCloudRecords([NSPredicate(key: "recordName", comparator: .In, value: deletedObjectIDs.recordNames)], context: context)
            self.session.localData.delete(objects: deletedObjectsRecords, context: context)
        }
                                                
        self.database.addOperation(operation)
        return true
    }
    
}
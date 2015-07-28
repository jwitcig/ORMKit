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
    
    public required init(session: ORSession, dataManager: ORDataManager) {
        self.session = session
        self.dataManager = dataManager
    }
    
    public func fetchAllOrganizations(completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: OROrganization.self, predicate: NSPredicate.allRows, completionHandler: completionHandler)
    }
    
    public func fetchAssociatedOrganizations(athlete unsafeAthlete: ORAthlete, completionHandler: ((ORCloudDataResponse)->())?) {
        let context = NSManagedObjectContext.contextForCurrentThread()
        
        let athlete = context.objectWithID(unsafeAthlete.objectID) as! ORAthlete
        
        let predicate = NSPredicate(key: "athletes", comparator: .Contains, value: athlete.reference)
        
        self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) {
            
            let context = NSManagedObjectContext.contextForCurrentThread()
            let athlete = context.objectWithID(unsafeAthlete.objectID) as! ORAthlete

            var compoundResults = $0.objects
        
            let predicate = NSPredicate(key: "admins", comparator: .Contains, value: athlete.reference)
            self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) {
                let recordNames: [String] = compoundResults.recordNames
                compoundResults += $0.objects.filter {
                    !recordNames.contains($0.recordID.recordName)
                }
                
                $0.results = compoundResults
                completionHandler?($0)
            }
        }
    }
    
    public func fetchLiftTemplates(session session: ORSession, completionHandler: ((ORCloudDataResponse)->())?) {
        guard let organization = session.currentOrganization else {
            completionHandler?(ORCloudDataResponse(error: ORDataTools.currentOrganizationMissingError))
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
        let predicate = NSPredicate(key: "liftTemplate", comparator: .Equals, value: template.reference)
        self.dataManager.fetchCloud(model: ORLiftEntry.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func fetchLiftEntries(templates templates: [ORLiftTemplate], completionHandler: ((ORCloudDataResponse)->())?) {
        let predicate = NSPredicate(key: "liftTemplate", comparator: .In, value: templates.references)
        self.dataManager.fetchCloud(model: ORLiftEntry.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func fetchMessages(organization organization: OROrganization, completionHandler: ((ORCloudDataResponse)->())?) {
        let predicate = NSPredicate(key: "organization", comparator: .Equals, value: organization.reference)
        self.dataManager.fetchCloud(model: ORMessage.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func save(model model: ORModel, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.saveCloud(record: model.record, completionHandler: completionHandler)
    }
    
    public func fetchAthletes(organization organization: OROrganization, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORAthlete.self, predicate: NSPredicate.allRows, completionHandler: completionHandler)
    }
    
    public func syncronizeDataToLocalStore(completionHandler: ((ORCloudDataResponse)->())? = nil) {
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
                }
            }
        }
    }
    
    public func syncronizeDataToCloudStore(completionHandler: ((ORDataResponse)->())? = nil) {
        var response: ORLocalDataResponse!
        defer { completionHandler?(response) }
        
        response = self.session.localData.fetchDirtyObjects(model: ORModel.self)
        guard response.success else { return }
        
        let recordsToSave = response.objects.records
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
//            print(records)
//            print(recordIDs)
//            print(error)
        }
        
        self.database.addOperation(operation)
    }
    
}
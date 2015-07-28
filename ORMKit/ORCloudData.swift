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
        self.dataManager.fetchCloud(model: OROrganization.self, predicate: ORDataTools.allRows, completionHandler: completionHandler)
    }
    
    public func fetchAssociatedOrganizations(athlete unsafeAthlete: ORAthlete, completionHandler: ((ORCloudDataResponse)->())?) {
        let context = NSManagedObjectContext.contextForCurrentThread()
        
        let athlete = context.objectWithID(unsafeAthlete.objectID) as! ORAthlete
        
        let predicate = ORDataTools.predicateWithKey("athletes", comparator: "CONTAINS", value: athlete.reference)
        
        self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) {
            
            let context = NSManagedObjectContext(concurrencyType: .ConfinementConcurrencyType)
            context.parentContext = ORSession.currentSession.localData.context
            let athlete = context.objectWithID(unsafeAthlete.objectID) as! ORAthlete

            var compoundResults = $0.objects
        
            let predicate = ORDataTools.predicateWithKey("admins", comparator: "CONTAINS", value: athlete.reference)
            self.dataManager.fetchCloud(model: OROrganization.self, predicate: predicate) {
                let recordNames: [String] = compoundResults.map { $0.recordID.recordName }
                compoundResults += $0.objects.filter {
                    !recordNames.contains($0.recordID.recordName)
                }
                
                $0.results = compoundResults
                completionHandler?($0)
            }
        }
    }
    
    public func fetchLiftTemplates(session session: ORSession, completionHandler: ((ORCloudDataResponse)->())?) {

        if session.soloSession {

        } else {
            if let organization = session.currentOrganization {
                self.fetchLiftTemplates(organizations: [organization], completionHandler: completionHandler)
            } else {
                let response = ORCloudDataResponse()
                response.error = ORDataTools.currentOrganizationMissingError
                completionHandler?(response)
            }
        }
    }
    
    public func fetchLiftTemplates(organizations organizations: [OROrganization], completionHandler: ((ORCloudDataResponse)->())?) {
        let references = organizations.map { $0.reference }
        let predicate = ORDataTools.predicateWithKey("organization", comparator: "IN", value: references)
        
        self.dataManager.fetchCloud(model: ORLiftTemplate.self, predicate: predicate, completionHandler: completionHandler)
    }

    public func fetchLiftEntries(template template: ORLiftTemplate, completionHandler: ((ORCloudDataResponse)->())?) {
        let predicate = ORDataTools.predicateWithKey("liftTemplate", comparator: "==", value: template.reference)
        self.dataManager.fetchCloud(model: ORLiftEntry.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func fetchLiftEntries(templates templates: [ORLiftTemplate], completionHandler: ((ORCloudDataResponse)->())?) {
        
        let predicate = ORDataTools.predicateWithKey("liftTemplate", comparator: "IN", value: ORLiftTemplate.references(models: templates))
        self.dataManager.fetchCloud(model: ORLiftEntry.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func fetchMessages(organization organization: OROrganization, completionHandler: ((ORCloudDataResponse)->())?) {
        let predicate = ORDataTools.predicateWithKey("organization", comparator: "==", value: organization.reference)
        self.dataManager.fetchCloud(model: ORMessage.self, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func save(model model: ORModel, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.saveCloud(record: model.record, completionHandler: completionHandler)
    }
    
    public func fetchAthletes(organization organization: OROrganization, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.fetchCloud(model: ORAthlete.self, predicate: ORDataTools.allRows, completionHandler: completionHandler)
    }
    
    public func syncronizeDataToLocalStore(completionHandler: ((ORCloudDataResponse)->())? = nil) {
        var childContext: NSManagedObjectContext!
        
        self.fetchAssociatedOrganizations(athlete: self.session.currentAthlete!) {
            childContext = NSManagedObjectContext.contextForCurrentThread()
            
            if $0.success {
                let organizations = OROrganization.organizations(records: $0.objects, context: childContext)
                self.session.localData.save(context: childContext)
                
                self.fetchLiftTemplates(organizations: organizations) {                    childContext = NSManagedObjectContext.contextForCurrentThread()
                    
                    if $0.success {
                
                        let templates = ORLiftTemplate.templates(records: $0.objects, context: childContext)
                        self.session.localData.save(context: childContext)
                        
                        completionHandler?($0)
                        
                        self.fetchLiftEntries(templates: templates) {
                            childContext = NSManagedObjectContext.contextForCurrentThread()

                            if $0.success {
                                ORLiftEntry.entries(records: $0.objects, context: childContext)
                                self.session.localData.save(context: childContext)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func syncronizeDataToCloudStore(completionHandler: ((ORDataResponse)->())? = nil) {
        var response: ORLocalDataResponse!
        defer { completionHandler?(response) }
        
        response = self.session.localData.fetchDirtyObjects(model: ORModel.self)
        guard response.success else { return }
        
        let dirtyModels = response.objects
        let recordsToSave = dirtyModels.map { $0.record }
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
//            print(records)
//            print(recordIDs)
//            print(error)
        }
        
        
        self.database.addOperation(operation)
    }
    
}
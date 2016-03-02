//
//  ORCloudData.swift
//  ORMKit
//
//  Created by Developer on 6/18/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
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
    
    public func fetchLiftTemplates(session session: ORSession, completionHandler: (([ORLiftTemplate], ORCloudDataResponse)->())?) {
        fatalError()
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
    
    public func save(model model: ORModel, completionHandler: ((ORCloudDataResponse)->())?) {
        self.dataManager.saveCloud(record: model.record, completionHandler: completionHandler)
    }
    
    public func syncronizeDataToLocalStore(completionHandler: ((ORCloudDataResponse)->())? = nil) -> Bool {
        guard !self.syncInProgress else {
            print("sync in progress")
            return false
        }
        self.syncInProgress = true
        
//        self.fetchAssociatedOrganizations(athlete: self.session.currentAthlete!) { (organizations, response) in
//            guard response.success else { return }
//            
//            self.session.localData.save(context: response.currentThreadContext)
//            
//            self.fetchLiftTemplates(organizations: organizations) { (liftTemplates, response) in
//                guard response.success else { return }
//                
//                self.session.localData.save(context: response.currentThreadContext)
//                
//                self.fetchLiftEntries(templates: liftTemplates) { (liftEntries, response) in
//                    guard response.success else { return }
//                    
//                    self.session.localData.save(context: response.currentThreadContext)
//                    
//                    completionHandler?(response)
//                    self.syncInProgress = false
//                }
//            }
//        }
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
            guard error == nil else { return }
            guard let record = completedRecord else { return }
            
            let context = NSManagedObjectContext.contextForCurrentThread()
            let model = ORModel.model(type: ORModel.self, record: record, context: context)
            
            self.session.localData.save(context: context)
            perRecordCompletionHandler?(ORCloudDataResponse(request: request, error: error, context: context))
        }
        
        operation.modifyRecordsCompletionBlock = { attemptedSaveRecords, attemptedDeleteRecordIDs, error in
            
            completionHandler?(ORCloudDataResponse(request: request, error: error))
            self.syncInProgress = false
            
            let context = NSManagedObjectContext.contextForCurrentThread()
            
            let (deletedObjectsRecords, _) = self.session.localData.fetchCloudRecords([NSPredicate(key: "recordName", comparator: .In, value: deletedObjectIDs.recordNames)], context: context)
            self.session.localData.delete(objects: deletedObjectsRecords, context: context)
        }
        
        self.database.addOperation(operation)
        return true
    }
    
}


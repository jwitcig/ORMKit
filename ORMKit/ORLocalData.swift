//
//  ORLocalData.swift
//  ORMKit
//
//  Created by Developer on 6/18/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORLocalData: DataConvenience {
    
    var dataManager: ORDataManager
    
    var session: ORSession
    
    public var context: NSManagedObjectContext {
        return self.dataManager.localDataCoordinator.managedObjectContext
    }
    
    public required init(session: ORSession, dataManager: ORDataManager) {
        self.session = session
        self.dataManager = dataManager
    }
    
    public func fetchObject<T: ORModel>(id id: String, model: T.Type, context: NSManagedObjectContext? = nil, options: ORDataOperationOptions? = nil) -> T? {
        
        
        let operationOptions = options != nil ? options! : ORDataOperationOptions()
        operationOptions.fetchLimit = 1
        
        let (objects, _) = self.dataManager.fetchLocal(model: model,
            predicates: [NSPredicate(key: "cloudRecord.recordName", comparator: .Equals, value: id)],
            context: context,
            options: operationOptions)
        
        return objects.first
    }
    
    public func fetchObject<T: ORModel>(record record: CKRecord, model: T.Type, context: NSManagedObjectContext? = nil, options: ORDataOperationOptions? = nil) -> T? {
        return self.fetchObject(id: record.recordID.recordName, model: model, context: context)
    }
    
    public func fetchObjects<T: ORModel>(ids ids: [String], model: T.Type, context: NSManagedObjectContext? = nil, options: ORDataOperationOptions? = nil) -> [T]? {
        let (objects, _) = self.dataManager.fetchLocal(model: model,
            predicates: [NSPredicate(key: "cloudRecord.recordName", comparator: .In, value: ids)],
            context: context,
            options: options)
        return objects
    }
    
    public func fetchObjects<T: ORModel>(records records: [CKRecord], model: T.Type, context: NSManagedObjectContext? = nil, options: ORDataOperationOptions? = nil) -> [T]? {
        return self.fetchObjects(ids: records.recordIDs.recordNames, model: model, context: context, options: options)
    }
    
    public func fetchObjects<T: ORModel>(model model: T.Type, predicates: [NSPredicate], context: NSManagedObjectContext? = nil, options: ORDataOperationOptions? = nil) -> ([T], ORLocalDataResponse) {
        let (objects, response) = self.dataManager.fetchLocal(entityName: model.recordType, predicates: predicates, context: context, options: options)
        return (objects as! [T], response)
    }
    
    public func fetchCloudRecords(predicates: [NSPredicate], context: NSManagedObjectContext? = nil) -> ([CloudRecord], ORLocalDataResponse) {
        let (objects, response) = self.dataManager.fetchLocal(entityName: CloudRecord.recordType, predicates: predicates, context: context)
        return (objects as! [CloudRecord], response)
    }
    
    public func fetchDirtyObjects<T: ORModel>(model model: T.Type) -> ([T], ORLocalDataResponse) {
        let (objects, response) = self.dataManager.fetchLocal(model: model,
            predicates: [NSPredicate(key: "cloudRecordDirty", comparator: .Equals, value: true)])
        
        return (objects.filter { $0.deleted == false }, response)
    }
    
    public func fetchDeletedIDs(context: NSManagedObjectContext? = nil) -> ([CKRecordID], ORLocalDataResponse) {
        let (objects, response) = self.dataManager.fetchLocal(
                            entityName: CloudRecord.recordType,
                            predicates: [NSPredicate(key: "model", comparator: .Equals, value: nil)],
                               context: context)
        let IDs = (objects as! [CloudRecord]).map { CKRecordID(recordName: $0.recordName) }
        return (IDs, response)
    }
    
    public func fetchAll<T: ORModel>(model model: T.Type, context: NSManagedObjectContext? = nil) -> ([T], ORLocalDataResponse) {
        return self.dataManager.fetchLocal(model: model, predicates: [NSPredicate.allRows], context: context)
    }
    
    public func save(context context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.dataManager.saveLocal(context: context)
    }
    
    public func delete(object object: NSManagedObject, context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.delete(objects: [object], context: context)
    }
    
    public func delete(objects objects: [NSManagedObject], context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.dataManager.delete(objects: objects, context: context)
    }
    
    public func deleteAll(model model: ORModel.Type) -> ORLocalDataResponse {
        let (models, response) = self.fetchAll(model: model)
        return response.success ? self.dataManager.delete(objects: models) : response
    }
    
    public func fetchLiftEntries(athlete athlete: ORAthlete, organization: OROrganization, template liftTemplate: ORLiftTemplate? = nil, options operationOptions: ORDataOperationOptions? = nil) -> ([ORLiftEntry], ORLocalDataResponse) {
        
        var predicates = [
            NSPredicate(key: "athlete", comparator: .Equals, value: athlete),
            NSPredicate(key: "organization", comparator: .Equals, value: organization)
        ]
        
        if let template = liftTemplate {
            predicates.append(
                NSPredicate(key: "liftTemplate", comparator: .Equals, value: template)
            )
        }
        
        return self.dataManager.fetchLocal(model: ORLiftEntry.self,
                                      predicates: predicates,
                                         options: operationOptions)
    }
        
}
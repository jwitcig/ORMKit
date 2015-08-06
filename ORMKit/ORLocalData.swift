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
        get { return self.dataManager.localDataCoordinator.managedObjectContext }
    }
    
    public required init(session: ORSession, dataManager: ORDataManager) {
        self.session = session
        self.dataManager = dataManager
    }
    
    public func fetchObject(id id: String, model: ORModel.Type, context: NSManagedObjectContext? = nil) -> ORModel? {
        return self.dataManager.fetchLocal(model: model,
            predicates: [NSPredicate(key: "cloudRecord.recordName", comparator: .Equals, value: id)],
            context: context,
            fetchLimit: 1).object
    }
    
    public func fetchObject(record record: CKRecord, model: ORModel.Type, context: NSManagedObjectContext? = nil) -> ORModel? {
        return self.fetchObject(id: record.recordID.recordName, model: model, context: context)
    }
    
    public func fetchObjects(ids ids: [String], model: ORModel.Type, context: NSManagedObjectContext? = nil) -> [ORModel]? {
        return self.dataManager.fetchLocal(model: model,
            predicates: [NSPredicate(key: "cloudRecord.recordName", comparator: .In, value: ids)],
            context: context).objects
    }
    
    public func fetchObjects(records records: [CKRecord], model: ORModel.Type, context: NSManagedObjectContext? = nil) -> [ORModel]? {
        return self.fetchObjects(ids: records.recordIDs.recordNames, model: model, context: context)
    }
    
    public func fetchObjects(model model: ORModel.Type, predicates: [NSPredicate], context: NSManagedObjectContext? = nil) -> [ORModel]? {
        return self.dataManager.fetchLocal(entityName: model.recordType, predicates: predicates, context: context).objects
    }
    
    public func fetchCloudRecords(predicates: [NSPredicate], context: NSManagedObjectContext? = nil) -> [CloudRecord] {
        return self.dataManager.fetchLocal(entityName: CloudRecord.recordType, predicates: predicates, context: context).dataObjects as! [CloudRecord]
    }
    
    public func fetchDirtyObjects(model model: ORModel.Type) -> ORLocalDataResponse {
        let response = self.dataManager.fetchLocal(model: model,
            predicates: [NSPredicate(key: "cloudRecordDirty", comparator: .Equals, value: true)])
        
        return ORLocalDataResponse(
            request: response.request,
            objects: response.objects.filter { $0.deleted == false },
              error: response.error,
            context: response.context)
    }
    
    public func fetchDeletedIDs(context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        let response = self.dataManager.fetchLocal(
                            entityName: CloudRecord.recordType,
                            predicates: [NSPredicate(key: "model", comparator: .Equals, value: nil)],
                               context: context)
        
        let IDs = (response.dataObjects as! [CloudRecord]).map { CKRecordID(recordName: $0.recordName) }
        return ORLocalDataResponse(request: response.request, objects: IDs, error: response.error, context: response.context)
    }
    
    public func fetchAll(model model: ORModel.Type, context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
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
        let response = self.fetchAll(model: model)
        return response.success ? self.dataManager.delete(objects: response.objects) : response
    }
    
    public func fetchLiftEntries(athlete athlete: ORAthlete, organization: OROrganization, template liftTemplate: ORLiftTemplate? = nil, order: Sort? = nil, options: ORDataOperationOptions? = nil) -> ORLocalDataResponse {
        
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
                                 sortDescriptors: order != nil ? [NSSortDescriptor(key: "date", order: order!)] : nil)
    }
        
}
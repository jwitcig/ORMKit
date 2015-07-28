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
        let predicate = NSPredicate(key: "cloudRecord.recordName", comparator: .Equals, value: id)
        let response = self.dataManager.fetchLocal(model: model, predicates: [predicate], context: context)
        
        return response.results.first as? ORModel
    }
    
    public func fetchDirtyObjects(model model: ORModel.Type) -> ORLocalDataResponse {
        return self.dataManager.fetchLocal(model: model, predicates: [NSPredicate(key: "cloudRecordDirty", comparator: .Equals, value: true)])
    }
    
    public func fetchObject(record record: CKRecord, model: ORModel.Type, context: NSManagedObjectContext? = nil) -> ORModel? {
        return self.fetchObject(id: record.recordID.recordName, model: model, context: context)
    }
    
    public func fetchObjects(ids ids: [String], model: ORModel.Type, context: NSManagedObjectContext? = nil) -> [ORModel]? {
        let predicate = NSPredicate(key: "cloudRecord.recordName", comparator: .In, value: ids)
        let response = self.dataManager.fetchLocal(model: model, predicates: [predicate], context: context)
        return response.objects
    }
    
    public func fetchObjects(records records: [CKRecord], model: ORModel.Type, context: NSManagedObjectContext? = nil) -> [ORModel]? {
        return self.fetchObjects(ids: records.recordNames, model: model, context: context)
    }
    
    public func fetchAll(model model: ORModel.Type, context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.dataManager.fetchLocal(model: model, predicates: [NSPredicate.allRows], context: context)
    }
    
    public func save(context context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.dataManager.saveLocal(context: context)
    }
    
    public func deleteAll(model model: ORModel.Type) -> ORLocalDataResponse {
        let response = self.fetchAll(model: model)
        guard response.success else { return response }
        return self.dataManager.delete(objects: response.objects)
    }
    
    public func fetchLiftEntries(athlete athlete: ORAthlete, organization: OROrganization, template liftTemplate: ORLiftTemplate? = nil, order: Sort? = nil) -> ORLocalDataResponse {
        
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
    
//    public func fetchLatestEntries(#template: ORLiftTemplate, organization: OROrganization) -> ORLocalDataResponse {
//        for athlete in organization.athletes 
//    }
    
}
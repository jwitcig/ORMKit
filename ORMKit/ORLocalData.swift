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
        let predicate = ORDataTools.predicateWithKey("cloudRecord.recordName", comparator: "==", value: id)
        let response = self.dataManager.fetchLocal(model: model, predicates: [predicate], context: context)
        
        return response.results.first as? ORModel
    }
    
    public func fetchDirtyObjects(model model: ORModel.Type) -> ORLocalDataResponse {
        return self.dataManager.fetchLocal(model: model, predicates: [ORDataTools.predicateWithKey("cloudRecordDirty", comparator: "==", value: true)])
    }
    
    public func fetchObject(record record: CKRecord, model: ORModel.Type, context: NSManagedObjectContext? = nil) -> ORModel? {
        return self.fetchObject(id: record.recordID.recordName, model: model, context: context)
    }
    
    public func fetchObjects(ids ids: [String], model: ORModel.Type, context: NSManagedObjectContext? = nil) -> [ORModel]? {
        let predicate = ORDataTools.predicateWithKey("cloudRecord.recordName", comparator: "IN", value: ids)
        let response = self.dataManager.fetchLocal(model: model, predicates: [predicate], context: context)
        
        return response.results as? [ORModel]
    }
    
    public func fetchObjects(records records: [CKRecord], model: ORModel.Type, context: NSManagedObjectContext? = nil) -> [ORModel]? {
        return self.fetchObjects(ids: records.map{$0.recordID.recordName}, model: model, context: context)
    }
    
    public func fetchAll(model model: ORModel.Type, context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.dataManager.fetchLocal(model: model, predicates: [ORDataTools.allRows], context: context)
    }
    
    public func save(context context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.dataManager.saveLocal(context: context)
    }
    
    public func deleteAll(model model: ORModel.Type) -> ORLocalDataResponse {
        let response = self.fetchAll(model: model)
        
        if response.success {
            let models = response.results as! [ORModel]
            return self.dataManager.delete(objects: models)
        } else {
            return response
        }
    }
    
    public func fetchLiftEntries(athlete athlete: ORAthlete, organization: OROrganization, template liftTemplate: ORLiftTemplate? = nil, order: Sort? = nil) -> ORLocalDataResponse {
        
        var predicates = [NSPredicate]()
        
        predicates.append(
            ORDataTools.predicateWithKey("athlete", comparator: "==", value: athlete)
        )
        if let template = liftTemplate {
            predicates.append(
                ORDataTools.predicateWithKey("liftTemplate", comparator: "==", value: template)
            )
        }
        predicates.append(
            ORDataTools.predicateWithKey("organization", comparator: "==", value: organization)
        )        
        var sortDescriptors: [NSSortDescriptor]?
        let key = "date"
        
        if let orderDescriptor = order {
            sortDescriptors = [
                NSSortDescriptor(key: key, order: .Chronological)
            ]
            
        }
        
        return self.dataManager.fetchLocal(model: ORLiftEntry.self, predicates: predicates, sortDescriptors: sortDescriptors)
    }
    
//    public func fetchLatestEntries(#template: ORLiftTemplate, organization: OROrganization) -> ORLocalDataResponse {
//        for athlete in organization.athletes 
//    }
    
}
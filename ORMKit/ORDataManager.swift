//
//  ORDataManager.swift
//  ORMKit
//
//  Created by Developer on 6/17/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORDataManager {
        
    public var localDataCoordinator: ORLocalDataCoordinator {
        didSet { localDataCoordinator.dataManager = self }
    }
    public var cloudDataCoordinator: ORCloudDataCoordinator {
        didSet { cloudDataCoordinator.dataManager = self }
    }
    
    public init(localDataContext: NSManagedObjectContext, cloudContainer: CKContainer, cloudDatabase: CKDatabase) {
        self.localDataCoordinator = ORLocalDataCoordinator(context: localDataContext)
        self.cloudDataCoordinator = ORCloudDataCoordinator(container: cloudContainer, database: cloudDatabase)
    }
    
    public func fetchLocal(model model: ORModel.Type, predicates: [NSPredicate]? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        var predicate: NSPredicate!
        if let filters = predicates {
            predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: filters)
            
        } else {
            predicate = NSPredicate(value: true)
        }
        return self.localDataCoordinator.fetch(model: model, predicate: predicate, sortDescriptors: sortDescriptors, context: context)
    }
    
    public func fetchCloud(model model: ORModel.Type, predicate: NSPredicate, completionHandler: ((ORCloudDataResponse)->())?) {
        self.cloudDataCoordinator.fetch(model: model, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func saveCloud(record record: CKRecord, completionHandler: ((ORCloudDataResponse)->())?) {
        self.cloudDataCoordinator.save(record: record, completionHandler: completionHandler)
    }
    
    public func saveLocal(context context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.localDataCoordinator.save(context: context)
    }
    
    public func delete(objects objects: [ORModel]) -> ORLocalDataResponse {
        return self.localDataCoordinator.delete(objects: objects)
    }
    
}

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
    
    public func fetchLocal<T: ORModel>(model model: T.Type, predicates: [NSPredicate]? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext? = nil, fetchLimit: Int = 0) -> ([T], ORLocalDataResponse) {
        let (objects, response) = self.fetchLocal(entityName: model.recordType,
                               predicates: predicates,
                          sortDescriptors: sortDescriptors,
                                  context: context,
                               fetchLimit: fetchLimit)
        return (objects as! [T], response)
    }
    
    public func fetchLocal(entityName entityName: String, predicates: [NSPredicate]? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext? = nil, fetchLimit: Int = 0) -> ([NSManagedObject], ORLocalDataResponse) {
        
        let predicate = predicates != nil ? NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicates!) : NSPredicate.allRows
        return self.localDataCoordinator.fetch(
            entityName: entityName,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            context: context,
            fetchLimit: fetchLimit)
    }
    
    public func fetchCloud<T: ORModel>(model model: T.Type, predicate: NSPredicate, options: ORDataOperationOptions? = nil, completionHandler: (([T], ORCloudDataResponse)->())?) {
        self.cloudDataCoordinator.fetch(model: model,
                                    predicate: predicate,
                                      options: options,
                            completionHandler: completionHandler)
    }
    
    public func saveCloud(record record: CKRecord, completionHandler: ((ORCloudDataResponse)->())?) {
        self.cloudDataCoordinator.save(record: record, completionHandler: completionHandler)
    }
    
    public func saveLocal(context context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.localDataCoordinator.save(context: context)
    }
    
    public func delete(objects objects: [NSManagedObject], context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.localDataCoordinator.delete(objects: objects, context: context)
    }
    
}

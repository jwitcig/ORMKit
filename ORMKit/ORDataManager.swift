//
//  ORDataManager.swift
//  ORMKit
//
//  Created by Developer on 6/17/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif
import CoreData
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
    
    public func fetchCloudIDs(predicate predicate: NSPredicate? = nil, completionHandler: ((([String: [CKRecordID]]), ORCloudDataResponse) -> ())?) {
        self.cloudDataCoordinator.fetchIDs(predicate, completionHandler: completionHandler)
    }
    
    public func fetchLocalIDs(model: ORModel.Type, predicate: NSPredicate? = nil, context: NSManagedObjectContext? = nil) -> ((String, [String]), ORLocalDataResponse) {
        let queryPredicate = predicate ?? NSPredicate.allRows

        return self.localDataCoordinator.fetchObjectIDs(entityName: model.recordType, predicate: queryPredicate, context: context)
    }
    
    public func fetchLocal<T: ORModel>(model model: T.Type, predicates: [NSPredicate]? = nil, context: NSManagedObjectContext? = nil, options: ORDataOperationOptions? = nil) -> ([T], ORLocalDataResponse) {
        let (objects, response) = self.fetchLocal(entityName: model.recordType,
                               predicates: predicates,
                                  context: context,
                                  options: options)
        return (objects as! [T], response)
    }
    
    public func fetchLocal(entityName entityName: String, predicates: [NSPredicate]? = nil, context: NSManagedObjectContext? = nil, options: ORDataOperationOptions? = nil) -> ([NSManagedObject], ORLocalDataResponse) {
        
        let predicate = predicates != nil ? NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicates!) : NSPredicate.allRows
        return self.localDataCoordinator.fetch(
            entityName: entityName,
             predicate: predicate,
               context: context,
               options: options)
    }
        
    public func fetchCloud<T: ORModel>(model model: T.Type, predicate: NSPredicate? = nil, options: ORDataOperationOptions? = nil, completionHandler: (([T], ORCloudDataResponse)->())?) {
        self.cloudDataCoordinator.fetch(model: model,
            predicate: predicate,
            options: options,
            completionHandler: completionHandler)
    }
    
    public func saveLocal(context context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.localDataCoordinator.save(context: context)
    }
    
    public func saveCloud(record record: CKRecord, completionHandler: ((ORCloudDataResponse)->())?) {
        self.cloudDataCoordinator.save(record: record, completionHandler: completionHandler)
    }
    
    public func delete(objects objects: [NSManagedObject], context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.localDataCoordinator.delete(objects: objects, context: context)
    }
    
}

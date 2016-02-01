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

public class ORDataManager {
        
    public var localDataCoordinator: ORLocalDataCoordinator {
        didSet { localDataCoordinator.dataManager = self }
    }
    
    public init(localDataContext: NSManagedObjectContext) {
        self.localDataCoordinator = ORLocalDataCoordinator(context: localDataContext)
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
    
    public func saveLocal(context context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.localDataCoordinator.save(context: context)
    }
    
    public func delete(objects objects: [NSManagedObject], context: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        return self.localDataCoordinator.delete(objects: objects, context: context)
    }
    
}

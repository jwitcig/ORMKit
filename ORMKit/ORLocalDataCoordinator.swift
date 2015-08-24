//
//  ORLocalRequest.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORLocalDataCoordinator: ORDataCoordinator {
    
    internal var managedObjectContext: NSManagedObjectContext
    
    internal init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    private func decideContext(context localContext: NSManagedObjectContext?) -> NSManagedObjectContext {
        return localContext != nil ? localContext! : self.managedObjectContext
    }
    
    public func fetch(entityName entityName: String, predicate: NSPredicate, context localContext: NSManagedObjectContext? = nil, options: ORDataOperationOptions? = nil) -> ([NSManagedObject], ORLocalDataResponse)  {
        
        let context = self.decideContext(context: localContext)
        
        let dataRequest = ORLocalDataRequest()
        
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = predicate
        request.includesSubentities = true
        
        if let operationOptions = options {
            request.sortDescriptors = operationOptions.sortDescriptors
            request.fetchLimit = operationOptions.fetchLimit
            request.includesPendingChanges = operationOptions.includesPendingChanges
        }
        
        var objects: [NSManagedObject]!
        var error: NSError?
        do {
            objects = try context.executeFetchRequest(request) as! [NSManagedObject]
        } catch let err as NSError {
            error = err
            objects = []
        }
        return (objects, ORLocalDataResponse(request: dataRequest, error: error, context: context))
    }
    
    public func save(context localContext: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        let context = self.decideContext(context: localContext)
        
        let dataRequest = ORLocalDataRequest()
        
        var error: NSError?
        do {
            try context.save()
        } catch let err as NSError {
            error = err
        }
        
        return ORLocalDataResponse(request: dataRequest, error: error, context: context)
    }
    
    public func delete(objects objects: [NSManagedObject], context localContext: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        let context = self.decideContext(context: localContext)

        let dataRequest = ORLocalDataRequest()
        
        for object in objects {
            context.deleteObject(object)
        }
        
        var error: NSError?
        do {
            try context.save()
        } catch let err as NSError {
            error = err
        }
        return ORLocalDataResponse(request: dataRequest,
                                     error: error,
                                   context: context)
    }
        
}
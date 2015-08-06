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
    
    public func fetch(entityName entityName: String, predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]? = nil, context localContext: NSManagedObjectContext? = nil, fetchLimit: Int = 0) -> ORLocalDataResponse  {
        
        let context = self.decideContext(context: localContext)
        
        let dataRequest = ORLocalDataRequest()
        
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.includesSubentities = true
        request.fetchLimit = fetchLimit
        
        var objects: [ORModel]!
        var error: NSError?
        do {
            objects = try context.executeFetchRequest(request) as! [ORModel]
        } catch let err as NSError {
            error = err
        }
        
        if fetchLimit == 1 {
            return ORLocalDataResponse(request: dataRequest, object: objects.first, error: error, context: context)
        }
        return ORLocalDataResponse(request: dataRequest, objects: objects, error: error, context: context)
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
                                   objects: error == nil ? objects : nil,
                                     error: error,
                                   context: context)
    }
        
}
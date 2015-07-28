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
    
    public func fetch(model model: ORModel.Type, predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]? = nil, context localContext: NSManagedObjectContext? = nil) -> ORLocalDataResponse  {
        
        var context: NSManagedObjectContext!
        if localContext != nil {
            context = localContext!
        } else {
            context = self.managedObjectContext
        }
        
        let request = NSFetchRequest(entityName: model.recordType)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.includesSubentities = true
        
        var error: NSError?
        let response = ORLocalDataResponse()
        do {
            let results = try context.executeFetchRequest(request)
            response.results = results
        } catch let error1 as NSError {
            error = error1
        }
        
        response.error = error
        return response
    }
    
    public func save(context localContext: NSManagedObjectContext? = nil) -> ORLocalDataResponse {
        var context: NSManagedObjectContext!
        if localContext != nil {
            context = localContext!
        } else {
            context = self.managedObjectContext
        }
        
        let response = ORLocalDataResponse()
        do {
            try context.save()
        } catch let error1 as NSError {
            response.error = error1
        }
        return response
    }
    
    public func delete(objects objects: [ORModel]) -> ORLocalDataResponse {
        for object in objects {
            self.managedObjectContext.deleteObject(object)
        }
        let response = ORLocalDataResponse()
        do {
            try self.managedObjectContext.save()
        } catch let error1 as NSError {
            response.error = error1
        }
        return response
    }
        
}
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
    
    internal var context: NSManagedObjectContext
    
    internal init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func fetch(#model: ORModel.Type, predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]? = nil) -> ORLocalDataResponse  {
        let request = NSFetchRequest(entityName: model.recordType)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.includesSubentities = true
        
        var error: NSError?
        var response = ORLocalDataResponse()
        if let results = context.executeFetchRequest(request, error: &error) {
            response.results = results
        }
        
        
        response.error = error
        return response
    }
    
    public func save() -> ORLocalDataResponse {
        var response = ORLocalDataResponse()
        self.context.save(&response.error)
        return response
    }
    
    public func delete(#objects: [ORModel]) -> ORLocalDataResponse {
        for object in objects {
            self.context.deleteObject(object)
        }
        var response = ORLocalDataResponse()
        self.context.save(&response.error)
        return response
    }
        
}
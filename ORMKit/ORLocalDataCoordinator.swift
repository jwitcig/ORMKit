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
    
    public func fetch(#model: ORModel.Type, predicate: NSPredicate) -> ORLocalDataResponse  {
        let request = NSFetchRequest(entityName: model.recordType)
        request.predicate = predicate
        
        var errorPtr = NSErrorPointer()
        var response = ORLocalDataResponse()
        response.results = context.executeFetchRequest(request, error: errorPtr)
        response.error = errorPtr.memory
        return response
    }
    
}
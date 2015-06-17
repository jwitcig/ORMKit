//
//  ORLocalRequest.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORLocalData {
    
    static let defaultContext = ORSession.currentSession.managedObjectContext
    
    public class func fetch(#model: ORModel.Type, predicate: NSPredicate) -> ORLocalDataResponse  {
        let request = NSFetchRequest(entityName: model.recordType)
        request.predicate = predicate
        
        var error = NSErrorPointer()
        
        var response = ORLocalDataResponse()
        response.results = defaultContext.executeFetchRequest(request, error: error)
        response.errorPointer = error
        return response
    }
    
}
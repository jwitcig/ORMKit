//
//  ORCloudRequest.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORCloudDataCoordinator: ORDataCoordinator {
    
    internal var container: CKContainer
    internal var database: CKDatabase
    
    internal init(container: CKContainer, database: CKDatabase) {
        self.container = container
        self.database = database
    }
    
    internal func fetch(#model: ORModel.Type, predicate: NSPredicate, completionHandler: ((ORCloudDataResponse)->())?) {
        let query = CKQuery(recordType: model.recordType, predicate: predicate)
        
        self.database.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            var response = ORCloudDataResponse()
            response.error = error
            response.results = results
            
            completionHandler?(response)
        }
    }
    
    internal func save(#record: CKRecord, completionHandler: ((ORCloudDataResponse)->())?) {
        println(completionHandler)

        
        self.database.saveRecord(record) { (record, error) -> Void in
            var response = ORCloudDataResponse()
            response.error = error
            println("hey")
            completionHandler?(response)
            println("bye")
            
        }
    }
    
}
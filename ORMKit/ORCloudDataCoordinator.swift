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
    
    internal func fetch(model model: ORModel.Type, predicate: NSPredicate, options: ORDataOperationOptions? = nil,completionHandler: ((ORCloudDataResponse)->())?) {
        let dataRequest = ORCloudDataRequest()
        let query = CKQuery(recordType: model.recordType, predicate: predicate)
        
        
        query.sortDescriptors = options!.sortDescriptors
        
        let queryOperation = CKQueryOperation(query: query)
        
        if let operationOptions = options {
            
            queryOperation.resultsLimit = operationOptions.fetchLimit
        }
        
        var records = [CKRecord]()
        queryOperation.recordFetchedBlock = {
            records.append($0)
        }
        queryOperation.queryCompletionBlock = { cursor, error in
            completionHandler?(ORCloudDataResponse(request: dataRequest, objects: records, error: error))
        }
        self.database.addOperation(queryOperation)
    }
    
    internal func save(record record: CKRecord, completionHandler: ((ORCloudDataResponse)->())?) {
        self.database.saveRecord(record) {
            completionHandler?(ORCloudDataResponse(request: ORCloudDataRequest(), objects: $0 != nil ? [$0!] : nil, error: $1))
        }
    }
    
}
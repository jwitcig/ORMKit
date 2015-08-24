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
    
    internal func fetch<T: ORModel>(model model: T.Type, predicate: NSPredicate, options: ORDataOperationOptions? = nil,completionHandler: (([T], ORCloudDataResponse)->())?) {
        let dataRequest = ORCloudDataRequest()
        
        let query = CKQuery(recordType: model.recordType, predicate: predicate)
        
        query.sortDescriptors = options?.sortDescriptors
        
        let queryOperation = CKQueryOperation(query: query)
        
        if let operationOptions = options {
            queryOperation.resultsLimit = operationOptions.fetchLimit
        }
        
        var records = [CKRecord]()
        queryOperation.recordFetchedBlock = { records.append($0) }
        queryOperation.queryCompletionBlock = { cursor, error in
            
            
            
            
            let context = NSManagedObjectContext.contextForCurrentThread()
            let models = ORModel.models(      type: model,
                                           records: records,
                                           context: context,
                    insertIntoManagedObjectContext: options != nil ? options!.insertResultsIntoManagedObjectContext : true)
            
            let response = ORCloudDataResponse(request: dataRequest, error: error, context: context)
            response.records = records
            
            completionHandler?(models, response)
        }
        self.database.addOperation(queryOperation)
    }
    
    internal func save(record record: CKRecord, completionHandler: ((ORCloudDataResponse)->())?) {
        let request = ORCloudDataRequest()
                
        self.database.saveRecord(record) {
            completionHandler?(ORCloudDataResponse(request: request, error: $1))
        }
    }
    
}
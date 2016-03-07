//
//  ORCloudRequest.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

public class ORCloudDataCoordinator: ORDataCoordinator {
    
    internal var container: CKContainer
    internal var database: CKDatabase
    
    internal init(container: CKContainer, database: CKDatabase) {
        self.container = container
        self.database = database
    }
    
    internal func fetchIDs(predicate: NSPredicate? = nil, completionHandler: ((([String: [CKRecordID]]), ORCloudDataResponse)->())?) {
        let dataRequest = ORCloudDataRequest()
        let operationQueue = NSOperationQueue()
        
        let completionOperation = NSOperation()
        
        var recordsData = [String: [CKRecordID]]()
        
        var queryOperations = ["completion": completionOperation]
        [ORAthlete.recordType, ORLiftTemplate.recordType, ORLiftEntry.recordType].forEach { recordType in
            
            recordsData[recordType] = [CKRecordID]()
           
            let queryPredicate = predicate ?? NSPredicate(value: true)
            let query = CKQuery(recordType: recordType, predicate: queryPredicate)
            
            let queryOperation = CKQueryOperation(query: query)
            queryOperation.database = database
            queryOperation.desiredKeys = ["recordName"]
            
            queryOperation.recordFetchedBlock = {
                recordsData[$0.recordType]?.append($0.recordID)
            }
            
            if recordType == ORLiftEntry.recordType {
                if let templateOperation = queryOperations[ORLiftTemplate.recordType] {
                    queryOperation.addDependency(templateOperation)
                }
            }
            
            queryOperations[recordType] = queryOperation
            completionOperation.addDependency(queryOperation)
        }
        
        completionOperation.completionBlock = {
            let context = NSManagedObjectContext.contextForCurrentThread()

            let response = ORCloudDataResponse(request: dataRequest, context: context)
            
            completionHandler?(recordsData, response)
        }
        
        let queryOperationsList = Array(queryOperations.values)
        operationQueue.addOperations(queryOperationsList, waitUntilFinished: true)
    }
    
    internal func fetch<T: ORModel>(model model: T.Type, predicate: NSPredicate? = nil, options: ORDataOperationOptions? = nil,completionHandler: (([T], ORCloudDataResponse)->())?) {
        let dataRequest = ORCloudDataRequest()
        
        let query = CKQuery(recordType: model.recordType, predicate: predicate ?? NSPredicate.allRows)        
        query.sortDescriptors = options?.sortDescriptors
        
        let queryOperation = CKQueryOperation(query: query)
        
        if let operationOptions = options {
            queryOperation.desiredKeys = operationOptions.desiredKeys
            queryOperation.resultsLimit = operationOptions.fetchLimit
        }
        
        var records = [CKRecord]()
        queryOperation.recordFetchedBlock = {
            records.append($0)
        }
        queryOperation.queryCompletionBlock = { cursor, error in
            let context = NSManagedObjectContext.contextForCurrentThread()
            let models = ORModel.models(type: model, records: records, context: context)
            
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
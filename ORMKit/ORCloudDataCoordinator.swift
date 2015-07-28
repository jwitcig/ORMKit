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
    
    internal func fetch(model model: ORModel.Type, predicate: NSPredicate, completionHandler: ((ORCloudDataResponse)->())?) {
        let query = CKQuery(recordType: model.recordType, predicate: predicate)
        self.database.performQuery(query, inZoneWithID: nil) {
            completionHandler?(ORCloudDataResponse(objects: $0, error: $1))
        }
    }
    
    internal func save(record record: CKRecord, completionHandler: ((ORCloudDataResponse)->())?) {
        self.database.saveRecord(record) {
            completionHandler?(ORCloudDataResponse(objects: $0 != nil ? [$0!] : nil, error: $1))
        }
    }
    
}
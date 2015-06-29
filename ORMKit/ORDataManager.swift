//
//  ORDataManager.swift
//  ORMKit
//
//  Created by Developer on 6/17/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORDataManager {
        
    public var localDataCoordinator: ORLocalDataCoordinator {
        didSet { localDataCoordinator.dataManager = self }
    }
    public var cloudDataCoordinator: ORCloudDataCoordinator {
        didSet { cloudDataCoordinator.dataManager = self }
    }
    
    public init(localDataContext: NSManagedObjectContext, cloudContainer: CKContainer, cloudDatabase: CKDatabase) {
        self.localDataCoordinator = ORLocalDataCoordinator(context: localDataContext)
        self.cloudDataCoordinator = ORCloudDataCoordinator(container: cloudContainer, database: cloudDatabase)
    }
    
    public func fetchLocal(#model: ORModel.Type, queryFilters: [(String, String, AnyObject)]?) -> ORLocalDataResponse {
        
        var predicate: NSPredicate!
        if let filters = queryFilters {
            
            var predicateString = ""
            for (key, comparator, value) in filters {
                predicateString += "\(key) \(comparator) \(value)"
            }
            
            predicate = NSPredicate(format: predicateString)
            
        } else {
            predicate = NSPredicate(value: true)
        }
        
        return self.localDataCoordinator.fetch(model: model, predicate: predicate)
    }
    
    public func fetchCloud(#model: ORModel.Type, predicate: NSPredicate, completionHandler: ((ORCloudDataResponse)->())?) {
        self.cloudDataCoordinator.fetch(model: model, predicate: predicate) { (response) -> () in
            completionHandler?(response)
        }
    }
    
    public func saveCloud(#record: CKRecord, completionHandler: ((ORCloudDataResponse)->())?) {
        self.cloudDataCoordinator.save(record: record, completionHandler: completionHandler)
    }
    
}

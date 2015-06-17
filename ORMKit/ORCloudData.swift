//
//  ORCloudRequest.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORCloudData {
    
    static var defaultDatabase = CKContainer.defaultContainer().publicCloudDatabase
    
    public class func fetch(#model: ORModel.Type, predicate: NSPredicate, options optionsDict: [String: AnyObject]?, completionHandler: ((ORCloudDataResponse)->())?) {
        
        let query = CKQuery(recordType: model.recordType, predicate: predicate)
        
        var database = ORCloudData.defaultDatabase
        if let options = optionsDict {
            
        }
        
        database.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            var response = ORCloudDataResponse()
            response.error = error
            response.results = results
            
            completionHandler?(response)
        }
    }
        
}
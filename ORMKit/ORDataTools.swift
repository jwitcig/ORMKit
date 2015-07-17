//
//  ORDataTools.swift
//  ORMKit
//
//  Created by Developer on 6/19/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit
internal class ORDataTools {
    
    internal class var allRows: NSPredicate {
        return NSPredicate(value: true)
    }
    
    internal class var currentOrganizationMissingError: NSError {
        return NSError(domain: "com.jwitapps.ORMKit", code: 500, userInfo: [NSLocalizedDescriptionKey: "Current organization not specified. [Missing current organization]"])
    }

    
    internal class func sortReverseChronological(#key: String) -> NSSortDescriptor {
        return NSSortDescriptor(key: key, ascending: false)
    }
    
    internal class func predicateWithKey(key: String, comparator: String, value: AnyObject) -> NSPredicate {
        return NSPredicate(format: "\(key) \(comparator) %@", value as! NSObject)
    }
    
}

public enum Sort {
    case Chronological
    case ReverseChronological
}
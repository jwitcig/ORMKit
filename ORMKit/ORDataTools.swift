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
    
    internal static func predicateWithKey(key: String, comparator: String, value: AnyObject) -> NSPredicate {
        return NSPredicate(format: "\(key) \(comparator) %@", value as! NSObject)
    }
    
}
//
//  ORDataTools.swift
//  ORMKit
//
//  Created by Developer on 6/19/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

import CloudKit

internal class ORDataTools {
    
    internal class var currentOrganizationMissingError: NSError {
        return NSError(domain: "com.jwitapps.ORMKit", code: 500, userInfo: [NSLocalizedDescriptionKey: "Current organization not specified. [Missing current organization]"])
    }
    
    internal class func sortReverseChronological(key key: String) -> NSSortDescriptor {
        return NSSortDescriptor(key: key, ascending: false)
    }
    
}

public enum Sort {
    case Chronological
    case ReverseChronological
}
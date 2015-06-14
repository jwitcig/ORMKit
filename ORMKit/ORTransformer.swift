//
//  ORTransformer.swift
//  ORMKit
//
//  Created by Developer on 6/14/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation


class ORTransformer: NSValueTransformer {
    
    override static func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override static func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        return value?.dataUsingEncoding(NSUTF8StringEncoding)
    }
}

  
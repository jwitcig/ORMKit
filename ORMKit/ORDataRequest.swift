//
//  ORDataRequest.swift
//  ORMKit
//
//  Created by Developer on 6/19/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation

class ORDataRequest {
    
    var predicates = [NSPredicate]()
    
    var timestamp = NSDate()
    
    var elapsedTimeSinceRequest: NSTimeInterval {
        return self.timestamp.timeIntervalSinceNow
    }
    
}
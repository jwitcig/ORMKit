//
//  ORCloudResponse.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation

public class ORDataResponse {
    
    public var results = [AnyObject]()
    public var error: NSError? {
        didSet {
            if let err = self.error {
                println(err)
            }
        }
    }
    
    public var success: Bool {
        return self.error == nil
    }
}
//
//  ORDataOperationOptions.swift
//  ORMKit
//
//  Created by Developer on 8/6/15.
//  Copyright © 2015 JwitApps. All rights reserved.
//

import Foundation

public class ORDataOperationOptions {

    public var fetchLimit = 0
    
    public var sortDescriptors = [NSSortDescriptor]()
    
    public var insertResultsIntoManagedObjectContext = true
    
    public init() { }
    
    public var includesPendingChanges = true
    
}
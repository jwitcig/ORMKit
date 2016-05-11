//
//  Extensions.swift
//  ORMKit
//
//  Created by Developer on 7/10/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

import CloudKit
import CoreData

extension NSManagedObjectContext {
    
    public convenience init(parentContext: NSManagedObjectContext? = nil) {
        var selfObject: NSManagedObjectContext!
        defer {
            NSNotificationCenter.defaultCenter().addObserver(selfObject, selector: Selector("managedObjectContextWillSave:"), name: NSManagedObjectContextWillSaveNotification, object: selfObject)
            NSNotificationCenter.defaultCenter().addObserver(selfObject, selector: Selector("managedObjectContextDidSave:"), name: NSManagedObjectContextDidSaveNotification, object: selfObject)
        }
        
        guard let parentManagedObjectContext = parentContext else {
            self.init(concurrencyType: .MainQueueConcurrencyType)
            selfObject = self
            return
        }
        
        self.init(concurrencyType: .PrivateQueueConcurrencyType)
        self.parentContext = parentManagedObjectContext
        selfObject = self
    }

}
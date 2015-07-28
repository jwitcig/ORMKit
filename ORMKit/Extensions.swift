//
//  Extensions.swift
//  ORMKit
//
//  Created by Developer on 7/10/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

extension String {
    
    var range: Range<String.Index> {
        return Range<String.Index>(start: self.startIndex, end: self.endIndex)
    }
    
    func isBefore(toString toString: String) -> Bool {
        return self.compare(toString, options: NSStringCompareOptions.CaseInsensitiveSearch, range: self.range, locale: nil) == .OrderedAscending
    }
    
}

extension NSDate {
    
    func isBefore(date date: NSDate) -> Bool {
        return self.compare(date) == .OrderedAscending
    }
    
    func isSameDay(date date: NSDate) -> Bool {
        return self.compare(date) == .OrderedSame
    }

    public class func daysBetween(startDate startDate: NSDate, endDate: NSDate) -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dateComponents = calendar.components(.Day, fromDate: startDate, toDate: endDate, options: NSCalendarOptions())
        return dateComponents.day
    }
    
    class func sorted(dates dates: [NSDate]) -> [NSDate] {
        return dates.sort { $0.0.isBefore(date: $0.1) }
    }
    
    func isBetween(firstDate firstDate: NSDate, secondDate: NSDate, inclusive: Bool) -> Bool {
        if self.isSameDay(date: firstDate) || self.isSameDay(date: secondDate) {
            if inclusive { return true }
            else { return false }
        }
        return firstDate.isBefore(date: self) && self.isBefore(date: secondDate)
    }
    
}

extension NSSortDescriptor {
    
    convenience init(key: String, order: Sort) {
        switch order {
        case .Chronological:
            self.init(key: key, ascending: true)
        case .ReverseChronological:
            self.init(key: key, ascending: false)
        }
    }
    
}

extension NSManagedObject {
    
    public var changedKeysForCloudKit: [String: AnyObject] {
        get {
            var dataDict = [String: AnyObject]()
            
            let keys = self.changedValues().keys.array
            for key in keys {
                
                let value = self.valueForKey(key)
                
                guard value as? CloudRecord == nil else { continue }
                
                guard value as? Set<ORModel> == nil else {
                    dataDict[key] = (value as! Set<ORModel>).map { $0.reference }
                    continue
                }
                
                guard let model = value as? ORModel else {
                    dataDict[key] = value
                    continue
                }
                
                dataDict[key] = model.reference
            }
            return dataDict
        }
    }
    
}

extension NSManagedObjectContext {
    
    convenience init(parentContext: NSManagedObjectContext) {
        self.init(concurrencyType: .ConfinementConcurrencyType)
        self.parentContext = parentContext
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("managedObjectContextDidSave:"), name: NSManagedObjectContextDidSaveNotification, object: self)
    }
    
    func managedObjectContextDidSave(notification: NSNotification) {
        let savedContext = notification.object as! NSManagedObjectContext
        
        let mainMOC = self.parentContext!
        
        // ignore change notifications for the main MOC
        guard mainMOC != savedContext else { return }
        
        guard mainMOC.persistentStoreCoordinator == savedContext.persistentStoreCoordinator else { return }
        
        runOnMainThread {
            mainMOC.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
    public func crossContextEquivalent(object object: NSManagedObject) -> NSManagedObject {
        return self.objectWithID(object.objectID)
    }
    
    public func crossContextEquivalents(objects objects: [NSManagedObject]) -> [NSManagedObject] {
        var equivalents = [NSManagedObject]()
        for object in objects {
            equivalents.append(self.crossContextEquivalent(object: object))
        }
        return equivalents
    }
    
    public class func contextForCurrentThread() -> NSManagedObjectContext {
        let thread = NSThread.currentThread()
    
        if let context = NSManagedObjectContext.threadContexts[thread] { return context }
        
        let newContext = NSManagedObjectContext(parentContext: ORSession.currentSession.localData.context)
        NSManagedObjectContext.threadContexts[thread] = newContext
        return newContext
    }
    
    private static var threadContexts = [NSThread: NSManagedObjectContext]()
    
}

let userInteractiveThread = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
let userInitiatedThread = dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
let backgroundThread = dispatch_get_global_queue(Int(QOS_CLASS_UNSPECIFIED.rawValue), 0)

func runOnMainThread(block: (()->())) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func runOnUserInteractiveThread(block: (()->())) {
    dispatch_async(userInteractiveThread, block)
}

func runOnUserInitiatedThread(block: (()->())) {
    dispatch_async(userInitiatedThread, block)
}

func runOnBackgroundThread(block: (()->())) {
    dispatch_async(backgroundThread, block)
}

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

extension CKQuery {
    
    convenience init(recordType: String) {
        self.init(recordType: recordType, predicate: NSPredicate.allRows)
    }
    
}

extension String {
    
    var range: Range<String.Index> {
        return Range<String.Index>(start: self.startIndex, end: self.endIndex)
    }
    
    public func isBefore(string toString: String) -> Bool {
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

extension NSPredicate {
    
    class var allRows: NSPredicate {
        return NSPredicate(value: true)
    }
    
    convenience init(key: String, comparator: PredicateComparator, value comparisonValue: AnyObject?) {
        guard let value = comparisonValue else {
            self.init(format: "\(key) \(comparator.rawValue) nil")
            return
        }
        
        var target = value
        if let arrayValue = value as? [CKReference] where arrayValue.count == 0 {
            target = [CKReference(recordID: CKRecordID(recordName: "!"), action: .None)]
        }
        
        self.init(format: "\(key) \(comparator.rawValue) %@", argumentArray: [target])
    }
    
}

extension NSSortDescriptor {
    
    public convenience init(key: String, order: Sort) {
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
            
            for key in Array(self.changedValues().keys) {
                let value = self.valueForKey(key)
                
                guard value as? CloudRecord == nil else { continue }
                
                guard value as? Set<ORModel> == nil else {
                    dataDict[key] = (value as! Set<ORModel>).references
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
        
        self.init(concurrencyType: .ConfinementConcurrencyType)
        self.parentContext = parentManagedObjectContext
        selfObject = self
    }
    
    func managedObjectContextWillSave(notification: NSNotification) {
        let context = notification.object as! NSManagedObjectContext
        
        var observedObjects = context.insertedObjects
        for item in context.updatedObjects {
            observedObjects.insert(item)
        }
                
        for object in observedObjects {
            guard let model = object as? ORModel else { continue }
            
            var rejectKeys = ["cloudRecord", "cloudRecordDirty"]
            if let entityName = object.entity.name {
                if let entityRejectKeys = ORModel.LocalOnlyFields[entityName] {
                    rejectKeys += entityRejectKeys
                }
            }
            
            let changedKeys = Array(model.changedValues().keys).filter {
                !rejectKeys.contains($0)
            }
            
            guard !model.cloudUpdateSinceSave else {
                model.cloudUpdateSinceSave = false
                model.cloudRecordDirty = false
                continue
            }
            
            if changedKeys.count == 0 {
                model.cloudRecordDirty = false
            } else {
                model.cloudRecordDirty = true
            }
        }
    }
    
    func managedObjectContextDidSave(notification: NSNotification) {
        let savedContext = notification.object as! NSManagedObjectContext
        
        let mainMOC = ORSession.currentSession.localData.context
        
        // ignore change notifications for the main MOC
        guard mainMOC != savedContext else { return }
        
        guard mainMOC.persistentStoreCoordinator == savedContext.persistentStoreCoordinator else { return }
                
        runOnMainThread {
            mainMOC.mergeChangesFromContextDidSaveNotification(notification)
            ORSession.currentSession.localData.save(context: mainMOC)
        }
    }
    
    public func crossContextEquivalent<T: NSManagedObject>(object object: T) -> T {
        return self.objectWithID(object.objectID) as! T
    }
    
    public func crossContextEquivalents<T: NSManagedObject>(objects objects: [T]) -> [T] {
        return objects.map { self.crossContextEquivalent(object: $0) }
    }
    
    public class func contextForCurrentThread() -> NSManagedObjectContext {
        return NSManagedObjectContext.contextForThread(NSThread.currentThread())
    }
    
    public class func contextForThread(thread: NSThread) -> NSManagedObjectContext {
        guard thread != NSThread.mainThread() else {
            return ORSession.currentSession.localData.context
        }
        
        if let context = NSManagedObjectContext.threadContexts[thread] { return context }
        
        let newContext = NSManagedObjectContext(parentContext: ORSession.currentSession.localData.context)
        NSManagedObjectContext.threadContexts[thread] = newContext
        return newContext
    }
    
    private static var threadContexts = [NSThread.mainThread(): ORSession.currentSession.localData.context]
    
}

extension CollectionType where Generator.Element : CKRecord {
    
    var recordIDs: [CKRecordID] { return self.map { $0.recordID } }
}

extension CollectionType where Generator.Element : CKReference {
    
    var recordIDs: [CKRecordID] { return self.map { $0.recordID } }
}

extension CollectionType where Generator.Element : CKRecordID {
    
    var recordNames: [String] { return self.map { $0.recordName } }
}

extension CollectionType where Generator.Element : ORModel {
    
    public var references: [CKReference] { return self.map { $0.reference } }
    public var records: [CKRecord] { return self.map { $0.record } }
    public var recordNames: [String] { return self.map { $0.recordName } }
}

extension Set {
    public var array: [Generator.Element] { return Array(self) }
}

public extension NSUserDefaults {
    subscript(key: String) -> AnyObject? {
        return self.valueForKey(key)
    }
}

enum PredicateComparator: String {
    case Equals = "=="
    case Contains = "CONTAINS"
    case In = "IN"
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

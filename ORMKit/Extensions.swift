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

extension CKRecord {

    func propertyForName<T>(name: String, defaultValue: T) -> T {
        guard let storedValue = self.valueForKey(name) as? T else { return defaultValue }
        return storedValue
    }
    
    func modelForName(name: String) -> ORModel? {
        guard let reference = self.valueForKey(name) as? CKReference else { return nil }
        return self.modelFromReference(reference)
    }
    
    func modelListForName(name: String) -> [ORModel]? {
        guard let references = self.valueForKey(name) as? [CKReference] else { return nil }
        return self.modelListFromReferences(references)
    }
    
    func modelFromReference(reference: CKReference) -> ORModel? {
        return ORSession.currentSession.localData.fetchObject(id: reference.recordID.recordName, model: ORModel.self)
    }
    
    func modelListFromReferences(references: [CKReference]) -> [ORModel]? {
        let recordNames = references.recordIDs.recordNames
        return ORSession.currentSession.localData.fetchObjects(ids: recordNames, model: ORModel.self, context: NSManagedObjectContext.contextForCurrentThread())
    }
   
    func referenceForName(name: String) -> CKReference? {
        return self[name] as? CKReference
    }
 
    func referencesForName(name: String) -> Set<CKReference> {
        let references = self[name] as? [CKReference]
        return references != nil ? Set(references!) : Set()
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

public extension NSDate {
    
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
    
    public func daysBetween(endDate endDate: NSDate) -> Int {
        return NSDate.daysBetween(startDate: self, endDate: endDate)
    }
    
    public class func daysBeforeToday(originalDate originalDate: NSDate) -> Int {
        return originalDate.daysBeforeToday()
    }
    
    public func daysBeforeToday() -> Int {
        return NSDate.daysBetween(startDate: self, endDate: NSDate())
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

public extension NSPredicate {
    
    class var allRows: NSPredicate {
        return NSPredicate(value: true)
    }
    
    public convenience init(key: String, comparator: PredicateComparator, value comparisonValue: AnyObject?) {
        guard let value = comparisonValue else {
            self.init(format: "\(key) \(comparator.rawValue) nil")
            return
        }
        
        self.init(format: "\(key) \(comparator.rawValue) %@", argumentArray: [value])
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
        (insertedObjects.array + updatedObjects.array).forEach {
            
            guard let model = $0 as? ORModel else { return }
            if Array(model.changedValues().keys) != ["lastCloudSaveDate"] {
                model.lastLocalSaveDate = NSDate()
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

public extension CollectionType where Generator.Element : ORLiftEntry {
    
    var sortedByDate: [ORLiftEntry] {
        return self.sort { $0.date.isBefore(date: $1.date) }
    }
    
    var sortedByReverseDate: [ORLiftEntry] {
        return self.sort { !$0.date.isBefore(date: $1.date) }
    }
}

public extension CollectionType where Generator.Element : ORModel {
   
    var records: [CKRecord] {
        return map { $0.record }
    }
    
    var references: [CKReference] {
        return map { $0.reference }
    }
}

extension CollectionType where Generator.Element : CKRecord {
    
    var recordIDs: [CKRecordID] { return map { $0.recordID } }
}

extension CollectionType where Generator.Element : CKReference {
    
    var recordIDs: [CKRecordID] { return map { $0.recordID } }
}

extension CollectionType where Generator.Element : CKRecordID {
    
    var recordNames: [String] { return map { $0.recordName } }
    var references: [CKReference] { return map { CKReference(recordID: $0, action: .None) } }
}

extension CollectionType where Generator.Element : ORModel {
    
    var recordNames: [String] { return map { $0.recordName } }
}

extension Set {
    public var array: [Generator.Element] { return Array(self) }
}

public extension NSUserDefaults {
    subscript(key: String) -> AnyObject? {
        return self.valueForKey(key)
    }
}

public enum PredicateComparator: String {
    case Equals = "=="
    case Contains = "CONTAINS"
    case In = "IN"
}

public extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    subscript (safe range: Range<Int>) -> [Element]? {
        var elements = [Element]()
        for index in range {
            if let element = self[safe: index] {
                elements.append(element)
            } else {
                return nil
            }
            
        }
        return elements
    }
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

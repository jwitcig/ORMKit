//
//  ORLiftEntry.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/11/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

public class ORLiftEntry: ORModel, ModelSubclassing {
    
    public static var recordType: String { return RecordType.ORLiftEntry.rawValue }
    public var date: NSDate!
    public var liftTemplate: ORLiftTemplate!
    public var maxOut: Bool!
    public var owner: ORUser!
    public var weightLifted: Int!
    public var reps: Int!
    
    required public init(context: NSManagedObjectContext) {
        super.init(entity: NSEntityDescription.entityForName(ORLiftEntry.recordType, inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
        self.record = CKRecord(recordType: ORLiftEntry.recordType)
    }
    
    convenience required public init(reference: CKReference, context: NSManagedObjectContext) {
        self.init(context: context)
        self.record = CKRecord(recordType: ORLiftEntry.recordType, recordID: reference.recordID)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: NSPredicate(value: true))
        }
    }
    
    public func saveToRecord() {
        self.record.setValue(self.date, forKey: "date")
        self.record.setValue(self.liftTemplate.reference, forKey: "liftTemplate")
        self.record.setValue(self.maxOut, forKey: "maxOut")
        self.record.setValue(self.owner.reference, forKey: "date")
        self.record.setValue(self.weightLifted, forKey: "weightLifted")
        self.record.setValue(self.reps, forKey: "reps")
    }
    
    public func readFromRecord() {
        self.date = self.record.valueForKey("date") as! NSDate
        self.liftTemplate = ORLiftTemplate(reference: self.record.valueForKey("liftTemplate") as! CKReference, context: ORSession.managedObjectContext)
        self.maxOut = self.record.valueForKey("maxOut") as! Bool
        self.owner = ORUser(reference: self.record.valueForKey("owner") as! CKReference, context: ORSession.managedObjectContext)
        self.weightLifted = self.record.valueForKey("weightLifted") as! Int
        self.reps = self.record.valueForKey("reps") as! Int
    }
}
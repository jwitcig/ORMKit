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
    
    public var date: NSDate { get { return record.valueForKey("date") as! NSDate }
        set { record.setValue(newValue, forKey: "date") }
    }
    public var liftTemplate: ORLiftTemplate { get {
            let ref = record.valueForKey("ORLiftTemplate") as! CKReference
            let rec = CKRecord(recordType: "ORLiftTemplate", recordID: ref.recordID)
            return ORLiftTemplate(record: rec)
        }
        set { record.setValue(newValue.reference, forKey: "ORLiftTemplate") }
    }
    public var maxOut: Bool { get { return record.valueForKey("maxOut") as! Bool }
        set { record.setValue(newValue, forKey: "maxOut") }
    }
    public var owner: ORUser { get {
            let ref = record.valueForKey("user") as! CKReference
            let rec = CKRecord(recordType: ORUser.recordType, recordID: ref.recordID)
            return ORUser(record: rec)
        }
        set { record.setValue(newValue.reference, forKey: "user") }
    }
    public var weightLifted: Int { get { return record.valueForKey("weightLifted") as! Int }
        set { record.setValue(newValue, forKey: "weightLifted") }
    }
    public var reps: Int { get { return record.valueForKey("reps") as! Int }
        set { record.setValue(newValue, forKey: "reps") }
    }
    
    override required public init() {
        super.init()
        self.record = CKRecord(recordType: ORLiftEntry.recordType)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: NSPredicate(value: true))
        }
    }
    
    public func saveToRecord() {
        var record = CKRecord(recordType: ORLiftEntry.recordType)
        record.setValue(self.date, forKey: "date")
        record.setValue(self.liftTemplate.reference, forKey: "liftTemplate")
        record.setValue(self.maxOut, forKey: "maxOut")
        record.setValue(self.owner.reference, forKey: "date")
        record.setValue(self.weightLifted, forKey: "weightLifted")
        record.setValue(self.reps, forKey: "reps")

    
    }
    
}
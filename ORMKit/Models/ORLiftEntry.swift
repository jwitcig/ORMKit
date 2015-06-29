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
    
    public enum Fields: String {
        case date = "date"
        case maxOut = "maxOut"
        case reps = "reps"
        case weightLifted = "weightLifted"
        case liftTemplate = "liftTemplate"
        case owner = "owner"
    }
    
    override public class var recordType: String { return RecordType.ORLiftEntry.rawValue }
    
    public var date: NSDate {
        get { return self.record.valueForKey(Fields.date.rawValue) as! NSDate }
        set { self.record.setValue(newValue, forKey: Fields.date.rawValue) }
    }
    public var maxOut: Bool {
        get { return self.record.valueForKey(Fields.maxOut.rawValue) as! Bool }
        set { self.record.setValue(newValue, forKey: Fields.maxOut.rawValue) }
    }
    public var reps: Int {
        get { return self.record.valueForKey(Fields.reps.rawValue) as! Int }
        set { self.record.setValue(newValue, forKey: Fields.reps.rawValue) }
    }
    public var weightLifted: Int {
        get { return self.record.valueForKey(Fields.weightLifted.rawValue) as! Int }
        set { self.record.setValue(newValue, forKey: Fields.weightLifted.rawValue) }
    }
    public var liftTemplate: ORLiftTemplate {
        get {
            let reference = self.record.valueForKey(Fields.liftTemplate.rawValue) as! CKReference
            return ORLiftTemplate(record: CKRecord(recordType: ORLiftTemplate.recordType, recordID: reference.recordID))
        }
        set { self.record.setValue(newValue.reference, forKey: Fields.liftTemplate.rawValue) }
    }
    public var owner: ORAthlete {
        get {
            let reference = self.record.valueForKey(Fields.owner.rawValue) as! CKReference
            return ORAthlete(record: CKRecord(recordType: ORAthlete.recordType, recordID: reference.recordID))
        }
        set { self.record.setValue(newValue.reference, forKey: Fields.owner.rawValue) }
    }
    
    required public init() {
        super.init(record: CKRecord(recordType: ORLiftEntry.recordType))
    }
    
    required public init(record: CKRecord) {
        super.init(record: record)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: NSPredicate(value: true))
        }
    }
    
}
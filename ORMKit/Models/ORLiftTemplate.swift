//
//  ORLiftTemplate.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/10/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

public class ORLiftTemplate: ORModel, ModelSubclassing {
    
    public static var recordType: String { return RecordType.ORLiftTemplate.rawValue }
    
    public var liftName: String { get { return record.valueForKey("liftName") as! String }
        set { record.setValue(newValue, forKey: "liftName") }
    }
    public var liftDescription: String {
        get { return record.valueForKey("liftDescription") as! String }
        set { record.setValue(newValue, forKey: "liftDescription") }
    }
    public var isDefault: Bool {
        get { return record.valueForKey("isDefault") as! Bool }
        set { record.setValue(newValue, forKey: "isDefault") }
    }
    public var liftEntries: [ORLiftEntry] {
        get { return record.valueForKey("liftDescription") as! [ORLiftEntry] }
        set {
            var refs = newValue.map { x in x.reference }
            record.setValue(refs, forKey: "liftDescription")
        }
    }
    public var creator: ORUser {
        get {
            let ref = record.valueForKey("creator") as! CKReference
            let rec = CKRecord(recordType: ORLiftTemplate.recordType, recordID: ref.recordID)
            return ORUser(record: rec)
        }
        set { record.setValue(newValue.reference, forKey: "creator") }
    }
    public var owner: ORUser {
        get { return record.valueForKey("owner") as! ORUser }
        set { record.setValue(newValue.reference, forKey: "owner") }
    }
    public var solo: Bool {
        get { return record.valueForKey("solo") as! Bool }
        set { record.setValue(newValue, forKey: "solo") }
    }
    
    public override required init() {
        super.init()
        self.record = CKRecord(recordType: ORLiftTemplate.recordType)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: NSPredicate(value: true))
        }
    }
    
}
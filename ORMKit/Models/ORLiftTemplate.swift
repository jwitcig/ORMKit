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
    
    enum Fields: String {
        case defaultLift = "default"
        case liftDescription = "liftDescription"
        case liftName = "liftName"
        case solo = "solo"
        case creator = "creator"
        case owner = "owner"
    }
    
    override public class var recordType: String { return RecordType.ORLiftTemplate.rawValue }
    
    public var defaultLift: Bool {
        get { return self.record.valueForKey(Fields.defaultLift.rawValue) as! Bool }
        set { self.record.setValue(newValue, forKey: Fields.defaultLift.rawValue) }
    }
    public var liftDescription: String {
        get { return self.record.valueForKey(Fields.liftDescription.rawValue) as! String }
        set { self.record.setValue(newValue, forKey: Fields.liftDescription.rawValue) }
    }
    public var liftName: String {
        get { return self.record.valueForKey(Fields.liftName.rawValue) as! String }
        set { self.record.setValue(newValue, forKey: Fields.liftName.rawValue) }
    }
    
    public var solo: Bool {
        get { return self.record.valueForKey(Fields.solo.rawValue) as! Bool }
        set { self.record.setValue(newValue, forKey: Fields.solo.rawValue) }
    }
    public var owner: ORModel {
        get {
            let reference = self.record.valueForKey(Fields.owner.rawValue) as! CKReference
            return ORModel(record: CKRecord(recordType: "", recordID: reference.recordID))
        }
        set { self.record.setValue(newValue.reference, forKey: Fields.owner.rawValue) }
    }
    
    required public init() {
        super.init(record: CKRecord(recordType: ORLiftTemplate.recordType))
    }
    
    required public init(record: CKRecord) {
        super.init(record: record)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: NSPredicate(value: true))
        }
    }
    
}
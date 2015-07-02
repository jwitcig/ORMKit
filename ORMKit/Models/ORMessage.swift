//
//  ORMessage.swift
//  ORMKit
//
//  Created by Developer on 7/1/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

public class ORMessage: ORModel, ModelSubclassing {

    enum Fields: String {
        case title = "title"
        case body = "body"
        case owner = "owner"
        case poster = "poster"
    }
    
    override public class var recordType: String { return RecordType.ORMessage.rawValue }
    
    public var title: String {
        get { return self.record.valueForKey(Fields.title.rawValue) as! String }
        set { self.record.setValue(newValue, forKey: Fields.title.rawValue) }
    }
    public var body: String {
        get { return self.record.valueForKey(Fields.body.rawValue) as! String }
        set { self.record.setValue(newValue, forKey: Fields.body.rawValue) }
    }
    public var owner: ORModel {
        get {
            let reference = self.record.valueForKey(Fields.owner.rawValue) as! CKReference
            return ORModel(record: CKRecord(recordType: "", recordID: reference.recordID))
        }
        set { self.record.setValue(newValue.reference, forKey: Fields.owner.rawValue) }
    }
    public var poster: ORAthlete {
        get {
            let reference = self.record.valueForKey(Fields.poster.rawValue) as! CKReference
            return ORAthlete(record: CKRecord(recordType: ORAthlete.recordType, recordID: reference.recordID))
        }
        set { self.record.setValue(newValue.reference, forKey: Fields.poster.rawValue) }
    }
    
    required public init() {
        super.init(record: CKRecord(recordType: ORMessage.recordType))
    }
    
    required public init(record: CKRecord) {
        super.init(record: record)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORMessage.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORMessage.recordType, predicate: NSPredicate(value: true))
        }
    }
    
}
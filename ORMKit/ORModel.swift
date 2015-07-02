//
//  ORModel.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/11/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

protocol ModelSubclassing {
    static func query(predicate: NSPredicate?) -> CKQuery
    
    init()
}

enum RecordType: String {
    case OROrganization = "OROrganization"
    case ORLiftTemplate = "ORLiftTemplate"
    case ORLiftEntry = "ORLiftEntry"
    
    case ORMessage = "ORMessage"
    
    case ORAthlete = "ORAthlete"
}

public class ORModel {
    
    public var record: CKRecord!
    public var reference: CKReference {
        return CKReference(record: self.record, action: CKReferenceAction.None)
    }
    
    class var recordType: String { return "" }
    
    required public init(record: CKRecord) {
        self.record = record
    }
    
    public class func query(recordType: String, predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: recordType, predicate: filter)
        }
        return CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    }
    
}

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
    init()
    static var recordType: String { get }
    static func query(predicate: NSPredicate?) -> CKQuery
}

enum RecordType: String {
    case ORLiftTemplate = "LiftTemplate"
    case ORLiftEntry = "LiftEntry"
    
    case ORUser = "User"
}

public class ORModel {
    var record: CKRecord!
    
    var reference: CKReference { get { return CKReference(record: self.record, action: CKReferenceAction.None) } }
    
    public convenience init(record: CKRecord) {
        self.init()
        self.record = record
    }
    
    public func save(completionHandler: (CKRecord!, NSError!) -> (Void)) {
        CKContainer.defaultContainer().publicCloudDatabase.saveRecord(self.record, completionHandler: { (record, error) -> Void in
            completionHandler(record, error)
        })
    }
    
}

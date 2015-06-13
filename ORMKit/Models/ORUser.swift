//
//  ORUser.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/11/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

public class ORUser: ORModel, ModelSubclassing {
    
    static public var recordType: String { return RecordType.ORUser.rawValue }
    
    required public init(context: NSManagedObjectContext) {
        super.init(entity: NSEntityDescription.entityForName(ORUser.recordType, inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
        self.record = CKRecord(recordType: ORUser.recordType)
    }
    
    convenience required public init(reference: CKReference, context: NSManagedObjectContext) {
        self.init(context: context)
        self.record = CKRecord(recordType: ORUser.recordType, recordID: reference.recordID)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORUser.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORUser.recordType, predicate: NSPredicate(value: true))
        }
    }
    
    public func saveToRecord() {

    }
    
    public func readFromRecord() {
        
    }
    
}

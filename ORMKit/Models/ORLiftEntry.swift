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
    
    override public class var recordType: String { return RecordType.ORLiftEntry.rawValue }
    
    public var date: NSDate!
    public var maxOut: Bool!
    public var reps: Int!
    public var weightLifted: Int!
    public var liftTemplate: ORLiftTemplate!
    public var owner: ORAthlete!
    
    public init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(ORLiftEntry.recordType, inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: NSPredicate(value: true))
        }
    }
    
    func prepareForSave() {
        self.saveToRecord()
    }
    
    override func saveToRecord() -> CKRecord {
        var record = CKRecord(recordType: ORLiftTemplate.recordType, recordID: CKRecordID(recordName: self.recordName))
        record.setValue(self.date, forKey: "date")
        record.setValue(self.liftTemplate.reference, forKey: "liftTemplate")
        record.setValue(self.maxOut, forKey: "maxOut")
        record.setValue(self.owner.reference, forKey: "date")
        record.setValue(self.weightLifted, forKey: "weightLifted")
        record.setValue(self.reps, forKey: "reps")
        return record
    }
    
}
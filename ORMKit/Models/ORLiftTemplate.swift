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
    
    override public class var recordType: String { return RecordType.ORLiftTemplate.rawValue }
    
    public var defaultLift: Bool!
    public var liftDescription: String!
    public var liftName: String!
    public var solo: Bool!
    public var creator: ORAthlete!
    public var owner: ORAthlete!

    public init(context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName(ORLiftTemplate.recordType, inManagedObjectContext: context)!
        
        
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: NSPredicate(value: true))
        }
    }
    
    func prepareForSave() {
        self.saveToRecord()
    }
    
    override func saveToRecord() -> CKRecord {
        var record = CKRecord(recordType: ORLiftTemplate.recordType, recordID: CKRecordID(recordName: self.recordName))
        record.setValue(self.liftName, forKey: "liftName")
        record.setValue(self.liftDescription, forKey: "liftDescription")
        record.setValue(self.defaultLift, forKey: "isDefault")
        record.setValue(self.creator.reference, forKey: "creator")
        record.setValue(self.owner.reference, forKey: "owner")
        record.setValue(self.solo, forKey: "solo")
        return record
    }
    
}
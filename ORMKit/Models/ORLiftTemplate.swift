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
    
    public var defaultLift: Bool!
    public var liftDescription: String!
    public var liftName: String!
    public var solo: Bool!
    public var creator: ORUser!
    public var owner: ORUser!
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    public init(context: NSManagedObjectContext) {
        let record = CKRecord(recordType: ORLiftTemplate.recordType)
        
        let entity = NSEntityDescription.entityForName(ORLiftTemplate.recordType, inManagedObjectContext: context)
        
        super.init(record: record, entity: entity!, context: context)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: NSPredicate(value: true))
        }
    }
    
    public func saveToRecord() {
        self.record.setValue(self.liftName, forKey: "liftName")
        self.record.setValue(self.liftDescription, forKey: "liftDescription")
        self.record.setValue(self.defaultLift, forKey: "isDefault")
        self.record.setValue(self.creator.reference, forKey: "creator")
        self.record.setValue(self.owner.reference, forKey: "owner")
        self.record.setValue(self.solo, forKey: "solo")
    }
    
    public func readFromRecord() {
        self.liftName = self.record.valueForKey("liftName") as! String
        self.liftDescription = self.record.valueForKey("liftDescription") as! String
        self.defaultLift = self.record.valueForKey("isDefault") as! Bool
//        self.creator = ORUser(reference: self.record.valueForKey("creator") as! CKReference, context: ORSession.managedObjectContext)
//        self.owner = ORUser(reference: self.record.valueForKey("owner") as! CKReference, context: ORSession.managedObjectContext)
        self.solo = self.record.valueForKey("solo") as! Bool
    }
    
}
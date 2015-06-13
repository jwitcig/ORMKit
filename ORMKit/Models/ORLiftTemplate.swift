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
    public var liftName: String!
    public var liftDescription: String!
    public var isDefault: Bool!
    public var liftEntries: [ORLiftEntry]!
    public var creator: ORUser!
    public var owner: ORUser!
    public var solo: Bool!
    
    required public init(context: NSManagedObjectContext) {
        super.init(entity: NSEntityDescription.entityForName(ORLiftTemplate.recordType, inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
        
        self.record = CKRecord(recordType: ORLiftTemplate.recordType)
    }
    
    convenience required public init(reference: CKReference, context: NSManagedObjectContext) {
        self.init(context: context)
        self.record = CKRecord(recordType: ORLiftTemplate.recordType, recordID: reference.recordID)
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
        self.record.setValue(self.isDefault, forKey: "isDefault")
        self.record.setValue(self.creator.reference, forKey: "creator")
        self.record.setValue(self.owner.reference, forKey: "owner")
        self.record.setValue(self.solo, forKey: "solo")
    }
    
    public func readFromRecord() {
        self.liftName = self.record.valueForKey("liftName") as! String
        self.liftDescription = self.record.valueForKey("liftDescription") as! String
        self.isDefault = self.record.valueForKey("isDefault") as! Bool
        self.creator = ORUser(reference: self.record.valueForKey("creator") as! CKReference, context: ORSession.managedObjectContext)
        self.owner = ORUser(reference: self.record.valueForKey("owner") as! CKReference, context: ORSession.managedObjectContext)
        self.solo = self.record.valueForKey("solo") as! Bool
    }
    
}
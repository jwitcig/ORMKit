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
    
    public static var recordType: String { return RecordType.ORLiftEntry.rawValue }
    
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
        self.record.setValue(self.date, forKey: "date")
        self.record.setValue(self.liftTemplate.reference, forKey: "liftTemplate")
        self.record.setValue(self.maxOut, forKey: "maxOut")
        self.record.setValue(self.owner.reference, forKey: "date")
        self.record.setValue(self.weightLifted, forKey: "weightLifted")
        self.record.setValue(self.reps, forKey: "reps")
        return self.record
    }
    
    func readFromRecord() {
        self.date = self.record.valueForKey("date") as! NSDate
//        self.liftTemplate = ORLiftTemplate(reference: self.record.valueForKey("liftTemplate") as! CKReference, context: ORSession.managedObjectContext)
        self.maxOut = self.record.valueForKey("maxOut") as! Bool
//        self.owner = ORAthlete(reference: self.record.valueForKey("owner") as! CKReference, context: ORSession.managedObjectContext)
        self.weightLifted = self.record.valueForKey("weightLifted") as! Int
        self.reps = self.record.valueForKey("reps") as! Int
    }
}
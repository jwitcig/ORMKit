//
//  OROrganization.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class OROrganization: ORModel, ModelSubclassing {
    
    @NSManaged public var orgName: String
    
    @NSManaged public var athletes: NSSet
    @NSManaged public var admins: NSSet
    
    var athleteRefs: [CKReference] {
        get { return (self.athletes.allObjects as! [ORAthlete]).map {x in x.reference} }
    }
    
    var adminRefs: [CKReference] {
        get { return (self.admins.allObjects as! [ORAthlete]).map {x in x.reference} }
    }
    
    override public class var recordType: String { return RecordType.OROrganization.rawValue }
    
    static public func organization(#context: NSManagedObjectContext) -> OROrganization {
        return NSEntityDescription.insertNewObjectForEntityForName(OROrganization.recordType, inManagedObjectContext: context) as! OROrganization
    }
    
    public class func query(predicate: NSPredicate?) -> CKQuery {
        return super.query(OROrganization.recordType, predicate: predicate)
    }
    
    func prepareForSave() {
    }
    
    override func saveToRecord() -> CKRecord {
        var record = CKRecord(recordType: OROrganization.recordType)
        record.setValue(self.orgName, forKey: "orgName")
//        record.setValue(self.athleteRefs, forKey: "athletes")
//        record.setValue(self.adminRefs, forKey: "admins")
        return record
    }
}


public extension OROrganization {
    func addAthlete(value: ORAthlete) {
        var mutableSet = NSMutableSet(set: self.athletes)
        mutableSet.addObject(value)
        self.athletes = NSSet(set: mutableSet)
    }
    
    func removeAthlete(value: ORAthlete) {
        var mutableSet = NSMutableSet(set: self.athletes)
        mutableSet.removeObject(value)
        self.athletes = NSSet(set: mutableSet)
    }
}


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
//    init(context: NSManagedObjectContext)
//    init(reference: CKReference, context: NSManagedObjectContext)
//    static var recordType: String { get }
    static func query(predicate: NSPredicate?) -> CKQuery
    func prepareForSave()
    func saveToRecord() -> CKRecord
//    func readFromRecord()
}

enum RecordType: String {
    case OROrganization = "OROrganization"
    case ORLiftTemplate = "ORLiftTemplate"
    case ORLiftEntry = "ORLiftEntry"
    
    case ORAthlete = "ORAthlete"
}

public class ORModel: NSManagedObject {
    
    public var record: CKRecord { return self.saveToRecord() }
    @NSManaged public var recordName: String?
    
    class var recordType: String { return "" }
    
    var reference: CKReference { get { return CKReference(recordID: CKRecordID(recordName: self.recordName), action: CKReferenceAction.None) } }
    
//    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//        self = NSEntityDescription.insertNewObjectForEntityForName(entity.name, inManagedObjectContext: context)
//        super.init(entity: entity, insertIntoManagedObjectContext: context)
//    }
    
    public class func query(recordType: String, predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: recordType, predicate: filter)
        }
        return CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    }
    
    func saveToRecord() -> CKRecord {
        return CKRecord(recordType: "none")
    }
    
}

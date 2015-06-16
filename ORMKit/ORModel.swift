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
    static var recordType: String { get }
    static func query(predicate: NSPredicate?) -> CKQuery
    func prepareForSave()
    func saveToRecord() -> CKRecord
//    func readFromRecord()
}

enum RecordType: String {
    case ORLiftTemplate = "ORLiftTemplate"
    case ORLiftEntry = "ORLiftEntry"
    
    case ORAthlete = "ORAthlete"
}

public class ORModel: NSManagedObject {
    var record: CKRecord {
        return self.saveToRecord()
    }
    @NSManaged public var recordName: String?
    
    var reference: CKReference { get { return CKReference(record: self.record, action: CKReferenceAction.None) } }
    
//    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//        self = NSEntityDescription.insertNewObjectForEntityForName(entity.name, inManagedObjectContext: context)
//        super.init(entity: entity, insertIntoManagedObjectContext: context)
//    }
    
    func saveToRecord() -> CKRecord {
        return CKRecord(recordType: "")
    }
}

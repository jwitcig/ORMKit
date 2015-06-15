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
    func saveToRecord()
    func readFromRecord()
}

enum RecordType: String {
    case ORLiftTemplate = "LiftTemplate"
    case ORLiftEntry = "LiftEntry"
    
    case ORUser = "Users"
}

public class ORModel: NSManagedObject {
    var record: CKRecord!
    @NSManaged public var recordName: String
    
    var reference: CKReference { get { return CKReference(record: self.record, action: CKReferenceAction.None) } }
    
    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    public init(record: CKRecord, entity: NSEntityDescription, context: NSManagedObjectContext) {

        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.record = record
    }
    
    public func delete(context: NSManagedObjectContext, save: Bool, error: NSErrorPointer?) -> Bool {
        context.deleteObject(self)
        
        if save {
            self.save(context, error: error)
        }
        return true
    }
    
    public func save(context: NSManagedObjectContext, error: NSErrorPointer?) -> Bool {
        if let errorPointer = error {
            return context.save(errorPointer)
        }
        return context.save(nil)
    }
    
}

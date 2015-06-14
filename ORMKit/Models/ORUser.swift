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
    
    @NSManaged public var username: String!
    public var password: String {
        get { return "--secure value--" }
        set {
            self.passwordData = self.hashPassword(newValue)
        }
    }
    
    @NSManaged var passwordData: NSData!
   
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    public init(context: NSManagedObjectContext) {
        let record = CKRecord(recordType: ORUser.recordType)
        
        let entity = NSEntityDescription.entityForName(ORUser.recordType, inManagedObjectContext: context)
        
        super.init(record: record, entity: entity!, context: context)
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORUser.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORUser.recordType, predicate: NSPredicate(value: true))
        }
    }
    
    func hashPassword(password: String) -> NSData {
        let transformer = ORTransformer()
        return transformer.transformedValue(password) as! NSData
    }
    
    public func checkPassword(attempt: String) -> Bool {
        return self.passwordData.isEqualToData(self.hashPassword(attempt))
    }
    
    public static func signUp(#username: String, password: String, context: NSManagedObjectContext, error: NSErrorPointer?) -> ORUser? {
        var user = ORUser(context: context)
        user.username = username
        user.password = password
        if user.save(context, error: error) {
            return user
        }
        return nil
    }
    
    public static func signIn(#username: String, password: String, context: NSManagedObjectContext, error: NSErrorPointer?) -> ORUser? {
        
        var request = NSFetchRequest(entityName: ORUser.recordType)
        request.predicate = NSPredicate(format: "username = %@", username)
        request.predicate = NSPredicate(value: true)
        request.returnsObjectsAsFaults = false
        let results = context.executeFetchRequest(request, error: nil) as? [ORUser]
        
        if let user = results?.first {
            if user.checkPassword(password) {
                return user
            }
            return nil
        }
        return nil
    }
    
    public func saveToRecord() {
        
    }
    
    public func readFromRecord() {
        
    }
    
}

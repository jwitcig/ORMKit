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
    
    public static func signUp(#context: NSManagedObjectContext, completionHandler: ((Bool, ORUser?, NSError)->())!) {
        
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler { (recordId, error) -> Void in
            
            var user: ORUser?
            if error == nil {
                user = ORUser(context: context)
                user!.recordName = recordId.recordName
                
                user!.save(context, error: nil)

            } else {
                println(error)
            }
            
            var success = false
            if user != nil { success = true }
            completionHandler(success, user, error)
        }
    }
    
    public static func signInWithCloud(#context: NSManagedObjectContext, cloudLoginCompletionHandler: ((CKAccountStatus, NSError)->())?) {
        
        if let completionHandler = cloudLoginCompletionHandler {
            CKContainer.defaultContainer().accountStatusWithCompletionHandler({ (status, error) -> Void in
                if status == CKAccountStatus.Available {
                    CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler({ (recordId, error) -> Void in
                        
//                        let query = ORUser.query(NSPredicate(format: "recordName = \(recordId.recordName)"))
                        let query = ORUser.query(NSPredicate(value: true))

                        
                        CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (results, error) -> Void in
                            
                            if error == nil {
                                if results.count == 1 {
                                    
                                    var user: ORUser = results.first as! ORUser
                                    ORUser.storeUser(user, context: context)
                                    ORUser.setCurrentUser(user)
                                }
                            } else {
                                println(error)
                            }
                            
                            completionHandler(status, error)
                        })
                    })
                }
            })
        }
    }
    
    public static func signInLocally(context: NSManagedObjectContext) -> (Bool, ORUser?) {
        let currentUserRecordName = NSUserDefaults.standardUserDefaults().objectForKey("currentUserRecordName") as? String
        if let recordName = currentUserRecordName {
            
            var request = NSFetchRequest(entityName: ORUser.recordType)
            request.predicate = NSPredicate(format: "recordName == \(recordName)")
            let results = context.executeFetchRequest(request, error: nil)
            
            if let user = results?.first as? ORUser {
                ORUser.setCurrentUser(user)
                return (true, user)
            }
        }
        return (false, nil)
    }
    
    public static func storeUser(user: ORUser, context: NSManagedObjectContext) {
        var request = NSFetchRequest(entityName: ORUser.recordType)
        request.predicate = NSPredicate(format: "recordName = \(user.recordName)")
        let results = context.executeFetchRequest(request, error: nil)
        if let existing = results?.first as? ORUser {
            context.deleteObject(existing)
        }
        
        user.save(context, error: nil)
        context.save(nil)
    }
    
    public static func setCurrentUser(user: ORUser) {
        NSUserDefaults.standardUserDefaults().setObject(user.recordName, forKey: "currentUserRecordName")
        let result = NSUserDefaults.standardUserDefaults().synchronize()
        
        if result {
            ORSession.currentSession.currentUser = user
        }
    }
    
    public func saveToRecord() {
        
    }
    
    public func readFromRecord() {
        
    }
    
}

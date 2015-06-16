//
//  ORAthlete.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/11/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

public class ORAthlete: ORModel, ModelSubclassing {
    
    static public var recordType: String { return RecordType.ORAthlete.rawValue }
    @NSManaged public var userRecordName: String

    static public func obj(#context: NSManagedObjectContext) -> ORAthlete {
                
        return NSEntityDescription.insertNewObjectForEntityForName(ORAthlete.recordType, inManagedObjectContext: context) as! ORAthlete
    }
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORAthlete.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORAthlete.recordType, predicate: NSPredicate(value: true))
        }
    }
    
    public static func signUp(#context: NSManagedObjectContext, completionHandler: ((Bool, ORAthlete?, NSError)->())?) {
        var recordId = CKRecordID(recordName: "Athlete")
        
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler { (recordId, error) -> Void in
            if error == nil {
                
                var athlete = ORAthlete.obj(context: context)
                athlete.userRecordName = recordId.recordName
                athlete.prepareForSave()
                
                CKContainer.defaultContainer().publicCloudDatabase.saveRecord(athlete.record, completionHandler: { (record, error) -> Void in
                    
                    if error == nil {
                        
                        var athlete: ORAthlete?
                        if error == nil {
                            athlete = ORAthlete.obj(context: context)
                            athlete!.recordName = recordId.recordName
                            
                            context.save(nil)
                            
                            
                        } else {
                            println(error)
                        }
                        
                        if let handler = completionHandler {
                            handler(athlete != nil, athlete, error)
                        }
                        
                    } else {
                        println(error)
                    }
                    
                })
                
            } else {
                println(error)
            }
        }
    }
    
    public static func signInWithCloud(#completionHandler: ((Bool, NSError?)->())?) {
        var context = ORSession.currentSession.managedObjectContext
        
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler({ (recordId, error) -> Void in
            
            if error == nil {
                let query: CKQuery = ORAthlete.query(NSPredicate(format: "%K == %@", "userRecordName", recordId.recordName))
                
                CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (results, error) -> Void in
                    
                    var success = false
                    if error == nil {
                        if results.count == 1 {
                            var athlete: ORAthlete = ORAthlete.athleteFromRecord(results.first! as! CKRecord, context: context)
                            println("context: \(athlete.managedObjectContext)")

                            ORAthlete.storeAthlete(athlete, context: context)
                            println("context: \(athlete.managedObjectContext?.retainsRegisteredObjects)")
                            ORAthlete.setCurrentAthlete(athlete)
                            success = true
                            context.save(nil)
                            
                        }
                    } else {
                        println(error)
                    }
                    
                    if let handler = completionHandler {
                        handler(success, error)
                    }
                    
                })
            } else {
                println(error)
            }
        })
    }
    
    public static func signInLocally(context: NSManagedObjectContext) -> (Bool, ORAthlete?) {
        let currentUserRecordName = NSUserDefaults.standardUserDefaults().objectForKey("currentUserRecordName") as? String
        if let recordName = currentUserRecordName {
            
            var request = NSFetchRequest(entityName: ORAthlete.recordType)
            request.predicate = NSPredicate(format: "recordName == \(recordName)")
            let results = context.executeFetchRequest(request, error: nil)
            
            if let athlete = results?.first as? ORAthlete {
                ORAthlete.setCurrentAthlete(athlete)
                return (true, athlete)
            }
        }
        return (false, nil)
    }
    
    public static func storeAthlete(athlete: ORAthlete, context: NSManagedObjectContext) {
        var request = NSFetchRequest(entityName: ORAthlete.recordType)
        request.predicate = NSPredicate(format: "%K == %@", "userRecordName", athlete.userRecordName)
        let results = context.executeFetchRequest(request, error: nil)
        if let existing = results?.first as? ORAthlete {
            context.deleteObject(existing)
        }
    }
    
    public static func setCurrentAthlete(athlete: ORAthlete) {
        NSUserDefaults.standardUserDefaults().setObject(athlete.userRecordName, forKey: "currentUserRecordName")
        let result = NSUserDefaults.standardUserDefaults().synchronize()
        if result {
            ORSession.currentSession.currentAthlete = athlete
        }
    }
    
    public func prepareForSave() {
        self.saveToRecord()
    }
    
    override func saveToRecord() -> CKRecord {
        var record: CKRecord!
        if let recordName = self.recordName {
            let recordId = CKRecordID(recordName: recordName)
            record = CKRecord(recordType: ORAthlete.recordType, recordID: recordId)
        } else {
            record = CKRecord(recordType: ORAthlete.recordType)
        }
        
        record.setObject(self.userRecordName, forKey: "userRecordName")
        return record
    }
    
    public static func athleteFromRecord(record: CKRecord, context: NSManagedObjectContext) -> ORAthlete {
        var athlete = ORAthlete.obj(context: context)
        athlete.userRecordName = record.valueForKey("userRecordName") as! String
        return athlete
    }
    
}

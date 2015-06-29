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
    
    enum Fields: String {
        case userRecordName = "userRecordName"
    }
    
    override public class var recordType: String { return RecordType.ORAthlete.rawValue }
    
    public var userRecordName: String {
        get { return self.record.valueForKey(Fields.userRecordName.rawValue) as! String }
    }
    
    required public init() {
        super.init(record: CKRecord(recordType: ORAthlete.recordType))
    }
    
    required public init(record: CKRecord) {
        super.init(record: record)
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
        
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler { (recordID, error) -> Void in
            if error == nil {
                
                var athlete = ORAthlete(record: CKRecord(recordType: ORAthlete.recordType, recordID: recordID))
                
                CKContainer.defaultContainer().publicCloudDatabase.saveRecord(athlete.record, completionHandler: { (record, error) -> Void in
                    
                    if error == nil {
                        
                        if error == nil {
                            
                            context.save(nil)
                            
                            
                        } else {
                            println(error)
                        }
                        
                        if let handler = completionHandler {
                            if error == nil {
                                handler(true, athlete, error)
                            } else {
                                handler(false, nil, error)
                            }
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
    
    public static func setCurrentAthlete(athlete: ORAthlete) {
        NSUserDefaults.standardUserDefaults().setObject(athlete.userRecordName, forKey: "currentUserRecordName")
        let result = NSUserDefaults.standardUserDefaults().synchronize()
        if result {
            ORSession.currentSession.currentAthlete = athlete
        }
    }
    
}

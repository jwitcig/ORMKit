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
    public typealias SelfClass = ORAthlete
  
    enum CloudFields: String {
        case userRecordName = "userRecordName"
    }
    enum LocalFields: String {
        case userRecordName = "userRecordName"
        case athleteOrganizations = "athleteOrganizations"
        case adminOrganizations = "adminOrganizations"
    }
    
    override public var record: CKRecord {
        get {
            let record = CKRecord(recordType: RecordType.ORAthlete.rawValue, recordID: CKRecordID(recordName: recordName))
            return record
        }
        set {
            self.recordName = newValue.recordID.recordName
            self.userRecordName = newValue.valueForKey(CloudFields.userRecordName.rawValue) as! String
        }
    }
    
    public class func athlete(record: CKRecord? = nil) -> SelfClass {
        return super.model(type: SelfClass.self, record: record) as! SelfClass
    }
    
    public class func athletes(#records: [CKRecord]) -> [SelfClass] {
        return super.models(type: SelfClass.self, records: records) as! [SelfClass]
    }
    
    override public class var recordType: String { return RecordType.ORAthlete.rawValue }
    
    @NSManaged public var userRecordName: String
    
    @NSManaged public var athleteOrganizations: Set<OROrganization>
    @NSManaged public var adminOrganizations: Set<OROrganization>

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
                
                var athlete = ORAthlete.athlete(record: CKRecord(recordType: ORAthlete.recordType, recordID: recordID))
                
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
    
    private func readFromLocalRecord(localRecord: NSManagedObject) {
        if let value = localRecord.valueForKey(LocalFields.userRecordName.rawValue) as? String { self.userRecordName = value }
    }
    
}

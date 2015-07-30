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
        case userRecordName
        case firstName
        case lastName
        
        
        enum LocalOnly: String {
            case athleteOrganizations
            case adminOrganizations
            
            static var allCases: [LocalOnly] {
                return [athleteOrganizations, adminOrganizations]
            }
            
            static var allValues: [String] {
                return LocalOnly.allCases.map { $0.rawValue }
            }
        }
    }
    public class func athlete(record record: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> ORAthlete {
        return super.model(type: ORAthlete.self, record: record, context: context)
    }
    
    public class func athletes(records records: [CKRecord], context: NSManagedObjectContext? = nil) -> [ORAthlete] {
        return super.models(type: ORAthlete.self, records: records, context: context)
    }
    
    override public class var recordType: String { return RecordType.ORAthlete.rawValue }
    
    @NSManaged public var userRecordName: String
    
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    
    public var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }
    
    @NSManaged public var athleteOrganizations: Set<OROrganization>
    @NSManaged public var adminOrganizations: Set<OROrganization>

    public static func signUp(context context: NSManagedObjectContext, completionHandler: ((Bool, ORAthlete?, NSError)->())?) {
        
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler { (recordID, error) -> Void in
            if error == nil {
                
                let athlete = ORAthlete.athlete(record: CKRecord(recordType: ORAthlete.recordType, recordID: recordID!))
                
                CKContainer.defaultContainer().publicCloudDatabase.saveRecord(athlete.record, completionHandler: { (record, error) -> Void in
                    
                    if error == nil {
                        
                        if error == nil {
                            
                            do {
                                try context.save()
                            } catch { }
                            
                        } else {
                            print(error)
                        }
                        
                        if let handler = completionHandler {
                            if error == nil {
                                handler(true, athlete, error!)
                            } else {
                                handler(false, nil,
                                    error!)
                            }
                        }
                        
                    } else {
                        print(error)
                    }
                    
                })
                
            } else {
                print(error)
            }
        }
    }
    
    public static func setCurrentAthlete(athlete: ORAthlete) {
        NSUserDefaults.standardUserDefaults().setObject(athlete.recordName, forKey: "currentUserRecordName")
        let result = NSUserDefaults.standardUserDefaults().synchronize()
        if result {
            ORSession.currentSession.currentAthlete = athlete
        }
    }
    
    override func writeValuesFromRecord(record: CKRecord) {
        super.writeValuesFromRecord(record)
        self.userRecordName = record.propertyForName(Fields.userRecordName.rawValue, defaultValue: "")
        self.firstName = record.propertyForName(Fields.firstName.rawValue, defaultValue: "")
        self.lastName = record.propertyForName(Fields.lastName.rawValue, defaultValue: "")
    }
    
}

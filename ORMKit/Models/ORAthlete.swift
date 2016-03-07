//
//  ORAthlete.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/11/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif
import CloudKit
import CoreData

public class ORAthlete: ORModel, ModelSubclassing {
  
    enum Fields: String {
        case firstName
        case lastName
        case username
        
        enum LocalOnly: String {
            case None
            
            static var allCases: [LocalOnly] {
                return []
            }
            
            static var allValues: [String] {
                return LocalOnly.allCases.map { $0.rawValue }
            }
        }
    }
    
    override public class var recordType: String { return RecordType.ORAthlete.rawValue }
        
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    
    @NSManaged public var username: String
    
    public var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }
    
    public class func athlete(context: NSManagedObjectContext? = nil) -> ORAthlete {
        return super.model(type: ORAthlete.self, context: context)
    }
    
    public static func getLastAthlete() -> ORAthlete? {
        
        guard let recordName = NSUserDefaults.standardUserDefaults().valueForKey("currentAthleteRecordName") else {
            return nil
        }
        
        let predicate = NSPredicate(key: "cloudRecord.recordName", comparator: .Equals, value: recordName)
        let (athletes, response) = ORSession.currentSession.localData.fetchObjects(model: ORAthlete.self, predicates: [predicate])
        
        guard response.success else { print("Error fetching athlete(s)"); return nil }
        return athletes.first
    }
    
    public static func setCurrentAthlete(athlete: ORAthlete) {
        
        NSUserDefaults.standardUserDefaults().setValue(athlete.recordName, forKey: "currentAthleteRecordName")
        
        let result = NSUserDefaults.standardUserDefaults().synchronize()
        
        if result {
            ORSession.currentSession.currentAthlete = athlete
        }
    }
    
    override func writeValuesFromRecord(record: CKRecord) {
        super.writeValuesFromRecord(record)
    }
    
}

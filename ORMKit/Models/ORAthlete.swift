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
    
    public static func setCurrentAthlete(athlete: ORAthlete) {
        
        NSUserDefaults.standardUserDefaults().setValue(athlete.username, forKey: "currentAthleteUsername")
        
        let result = NSUserDefaults.standardUserDefaults().synchronize()
        
        if result {
            ORSession.currentSession.currentAthlete = athlete
        }
    }
    
}

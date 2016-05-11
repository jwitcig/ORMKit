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
import CoreData

public class ORAthlete: ORModel {
  
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
    
    override public class var entityName: String { return RecordType.ORAthlete.rawValue }
    
    public var firstName: String!
    public var lastName: String!
    
    public var identityID: String { return id }
    
    public var fullName: String {
        return "\(firstName) \(lastName)"
    }

    public static func getLastAthlete() -> ORAthlete? {
        
        guard let identityID = NSUserDefaults.standardUserDefaults().valueForKey("currentAthleteIdentityID") as? String else {
            return nil
        }
        
        let predicate = NSPredicate(key: "identityID", comparator: .Equals, value: identityID)
        let (athletes, response) = ORSession.currentSession.localData.fetchObjects(model: ORAthlete.self, predicates: [predicate])
        
        guard response.success else { print("Error fetching athlete(s)"); return nil }
        return athletes.first
    }
    
    public static func setCurrentAthlete(athlete: ORAthlete) {
        
        NSUserDefaults.standardUserDefaults().setValue(athlete.identityID, forKey: "currentAthleteIdentityID")
        
        let result = NSUserDefaults.standardUserDefaults().synchronize()
        
        if result {
            ORSession.currentSession.currentAthlete = athlete
        }
    }
    
}

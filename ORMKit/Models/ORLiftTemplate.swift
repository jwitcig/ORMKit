//
//  ORLiftTemplate.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/10/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif
import CloudKit
import CoreData

public class ORLiftTemplate: ORModel, ModelSubclassing {
    
    enum Fields: String {
        case defaultLift
        case liftDescription
        case liftName
        case solo
        case creator
        case organization
        
        enum LocalOnly: String {
            case NoFields
            
            static var allCases: [LocalOnly] {
                return []
            }
            
            static var allValues: [String] {
                return LocalOnly.allCases.map { $0.rawValue }
            }
        }
    }
    
    override public class var recordType: String { return RecordType.ORLiftTemplate.rawValue }
    
    public class func template(record: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> ORLiftTemplate {
        return super.model(type: ORLiftTemplate.self, context: context)
    }
    
    @NSManaged public var defaultLift: NSNumber
    @NSManaged public var liftDescription: String
    @NSManaged public var liftName: String
    
    @NSManaged public var solo: NSNumber
    
    @NSManaged public var creator: ORAthlete
    
//    public func updatedRecently(athlete athlete: ORAthlete, maxNumberOfDays: Int = 14) -> Bool? {
//        ORSession.currentSession.localData.fetchLiftEntries(athlete: <#T##ORAthlete#>, organization: <#T##OROrganization#>, template: <#T##ORLiftTemplate?#>, order: <#T##Sort?#>)
//    }
    
}
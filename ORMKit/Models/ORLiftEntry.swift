//
//  ORLiftEntry.swift
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

public class ORLiftEntry: ORModel, ModelSubclassing {

    public enum Fields: String {
        case date
        case maxOut
        case reps
        case weightLifted
        case liftTemplate
        case organization
        case athlete
        
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
    
    override public class var recordType: String { return RecordType.ORLiftEntry.rawValue }
    
    public class func entry(record: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> ORLiftEntry {
        return super.model(type: ORLiftEntry.self, context: context)
    }
    
    @NSManaged public var date: NSDate
    @NSManaged public var maxOut: Bool
    @NSManaged public var reps: NSNumber
    @NSManaged public var weightLifted: NSNumber
    public var max: NSNumber {
        return ORLiftEntry.oneRepMax(weightLifted: weightLifted.floatValue, reps: reps.floatValue)
    }
    
    public class func oneRepMax(weightLifted weightLifted: Float, reps: Float) -> NSNumber {
        guard reps != 1 else { return NSNumber(float: weightLifted) }
        
        let rounded = round( weightLifted + (weightLifted * reps * 0.033 ) )
        return NSNumber(float: rounded)
    }
    @NSManaged public var liftTemplate: ORLiftTemplate
    @NSManaged public var athlete: ORAthlete
    
    
}
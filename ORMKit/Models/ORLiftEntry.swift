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
import CoreData

public class ORLiftEntry: ORModel {

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
    
    override public class var entityName: String { return RecordType.ORLiftEntry.rawValue }
        
    public var date: NSDate = NSDate()
    public var maxOut: Bool = true
    public var reps: Int!
    public var weightLifted: Int!
    public var max: Int {
        return ORLiftEntry.oneRepMax(weightLifted: weightLifted, reps: reps)
    }
    
    public class func oneRepMax(weightLifted weightLifted: Int, reps: Int) -> Int {
        guard reps != 1 else { return weightLifted }
        
        let rounded = round( Float(weightLifted) + (Float(weightLifted * reps) * 0.033 ) )
        return Int(rounded)
    }
    public var liftTemplate: ORLiftTemplate!
    public var athlete: ORAthlete!
    
}
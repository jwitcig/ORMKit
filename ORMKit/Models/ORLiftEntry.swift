//
//  ORLiftEntry.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/11/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

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
        return super.model(type: ORLiftEntry.self, record: record, context: context)
    }
    
    public class func entries(records records: [CKRecord], context: NSManagedObjectContext? = nil) -> [ORLiftEntry] {
        return super.models(type: ORLiftEntry.self, records: records, context: context)
    }
    
    @NSManaged public var date: NSDate
    @NSManaged public var maxOut: Bool
    @NSManaged public var reps: NSNumber
    @NSManaged public var weightLifted: NSNumber
    public var max: NSNumber {
        let rounded = round( weightLifted.floatValue + (weightLifted.floatValue * reps.floatValue * 0.033 ) )
        return NSNumber(float: rounded)
    }
    @NSManaged public var organization: OROrganization?
    @NSManaged public var liftTemplate: ORLiftTemplate
    @NSManaged public var athlete: ORAthlete
    
    override func writeValuesFromRecord(record: CKRecord) {
        super.writeValuesFromRecord(record)
        
        guard let context = self.managedObjectContext else { return }
        
        self.date = record.propertyForName(Fields.date.rawValue, defaultValue: NSDate())
        self.maxOut = record.propertyForName(Fields.maxOut.rawValue, defaultValue: true)
        self.reps = record.propertyForName(Fields.reps.rawValue, defaultValue: 0)
        self.weightLifted = record.propertyForName(Fields.weightLifted.rawValue, defaultValue: 0)
        if let value = record.modelForName(Fields.liftTemplate.rawValue) as? ORLiftTemplate {
            self.liftTemplate = context.crossContextEquivalent(object: value)
        }
        if let value = record.modelForName(Fields.organization.rawValue) as? OROrganization {
            self.organization = context.crossContextEquivalent(object: value)
        }
        if let value = record.modelForName(Fields.athlete.rawValue) as? ORAthlete {
            self.athlete = context.crossContextEquivalent(object: value)
        }
    }
    
}
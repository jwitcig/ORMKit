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

    public enum CloudFields: String {
        case date = "date"
        case maxOut = "maxOut"
        case reps = "reps"
        case weightLifted = "weightLifted"
        case liftTemplate = "liftTemplate"
        case organization = "organization"
        case athlete = "athlete"
    }
    public enum LocalFields: String {
        case date = "date"
        case maxOut = "maxOut"
        case reps = "reps"
        case weightLifted = "weightLifted"
        case liftTemplate = "liftTemplate"
        case organization = "organization"
        case athlete = "athlete"
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
        
        self.date = record.propertyForName(CloudFields.date.rawValue, defaultValue: NSDate())
        self.maxOut = record.propertyForName(CloudFields.maxOut.rawValue, defaultValue: true)
        self.reps = record.propertyForName(CloudFields.reps.rawValue, defaultValue: 0)
        self.weightLifted = record.propertyForName(CloudFields.weightLifted.rawValue, defaultValue: 0)
        if let value = record.modelForName(CloudFields.liftTemplate.rawValue) as? ORLiftTemplate {
            self.liftTemplate = context.crossContextEquivalent(object: value) as! ORLiftTemplate
        }
        if let value = record.modelForName(CloudFields.organization.rawValue) as? OROrganization {
            self.organization = context.crossContextEquivalent(object: value) as? OROrganization
        }
        if let value = record.modelForName(CloudFields.athlete.rawValue) as? ORAthlete {
            self.athlete = context.crossContextEquivalent(object: value) as! ORAthlete
        }
    }
    
}
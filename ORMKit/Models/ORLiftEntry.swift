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
    public typealias SelfClass = ORLiftEntry

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
    
    override public var record: CKRecord {
        get {
            let record = CKRecord(recordType: RecordType.ORLiftEntry.rawValue, recordID: CKRecordID(recordName: recordName))
                
            record.setValue(self.date, forKey: CloudFields.date.rawValue)
            record.setValue(self.maxOut, forKey: CloudFields.maxOut.rawValue)
            record.setValue(self.reps, forKey: CloudFields.reps.rawValue)
            record.setValue(self.weightLifted, forKey: CloudFields.weightLifted.rawValue)
            record.setValue(self.liftTemplate.reference, forKey: CloudFields.liftTemplate.rawValue)
            record.setValue(self.organization?.reference, forKey: CloudFields.organization.rawValue)
            record.setValue(self.athlete.reference, forKey: CloudFields.athlete.rawValue)
            return record
        }
        set {
            self.recordName = newValue.recordID.recordName
            self.date = newValue.propertyForName(CloudFields.date.rawValue, defaultValue: NSDate()) as! NSDate
            self.maxOut = newValue.propertyForName(CloudFields.maxOut.rawValue, defaultValue: true) as! Bool
            self.reps = newValue.propertyForName(CloudFields.reps.rawValue, defaultValue: 0) as! NSNumber
            self.weightLifted = newValue.propertyForName(CloudFields.weightLifted.rawValue, defaultValue: 0) as! NSNumber
            if let value = newValue.modelForName(CloudFields.liftTemplate.rawValue) as? ORLiftTemplate {
                self.liftTemplate = value
            }
            if let value = newValue.modelForName(CloudFields.organization.rawValue) as? OROrganization {
                self.organization = value
            }
            if let value = newValue.modelForName(CloudFields.athlete.rawValue) as? ORAthlete {
                self.athlete = value
            }
        }
    }
    
    override public class var recordType: String { return RecordType.ORLiftEntry.rawValue }
    
    public class func entry(record: CKRecord? = nil) -> SelfClass {
        return super.model(type: SelfClass.self, record: record) as! SelfClass
    }
    
    public class func entries(#records: [CKRecord]) -> [SelfClass] {
        return super.models(type: SelfClass.self, records: records) as! [SelfClass]
    }
    
    @NSManaged public var date: NSDate
    @NSManaged public var maxOut: Bool
    @NSManaged public var reps: NSNumber
    @NSManaged public var weightLifted: NSNumber
    public var max: NSNumber {
        return NSNumber(float: weightLifted.floatValue + (weightLifted.floatValue * reps.floatValue * 0.033) )
    }
    @NSManaged public var organization: OROrganization?
    @NSManaged public var liftTemplate: ORLiftTemplate
    @NSManaged public var athlete: ORAthlete
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftEntry.recordType, predicate: NSPredicate(value: true))
        }
    }
    
}
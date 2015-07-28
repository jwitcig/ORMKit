//
//  ORLiftTemplate.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/10/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

public class ORLiftTemplate: ORModel, ModelSubclassing {
    
    enum CloudFields: String {
        case defaultLift = "default"
        case liftDescription = "liftDescription"
        case liftName = "liftName"
        case solo = "solo"
        case creator = "creator"
        case organization = "organization"
    }
    enum LocalFields: String {
        case defaultLift = "defaultLift"
        case liftDescription = "liftDescription"
        case liftName = "liftName"
        case solo = "solo"
        case creator = "creator"
        case organization = "organization"
    }
    
    override public class var recordType: String { return RecordType.ORLiftTemplate.rawValue }
    
    public class func template(record: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> ORLiftTemplate {
        return super.model(type: ORLiftTemplate.self, record: record, context: context) as! ORLiftTemplate
    }
    
    public class func templates(records records: [CKRecord], context: NSManagedObjectContext? = nil) -> [ORLiftTemplate] {
        return super.models(type: ORLiftTemplate.self, records: records, context: context) as! [ORLiftTemplate]
    }
    @NSManaged public var defaultLift: NSNumber
    @NSManaged public var liftDescription: String
    @NSManaged public var liftName: String
    
    @NSManaged public var solo: NSNumber
    
    @NSManaged public var organization: OROrganization?
    
    @NSManaged public var creator: ORAthlete
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: NSPredicate(value: true))
        }
    }
    
    override func writeValuesFromRecord(record: CKRecord) {
        super.writeValuesFromRecord(record)
        
        guard let context = self.managedObjectContext else { return }
        
        self.liftName = record.propertyForName(CloudFields.liftName.rawValue, defaultValue: "") as! String
        self.defaultLift = NSNumber(bool: record.propertyForName(CloudFields.defaultLift.rawValue, defaultValue: true) as! Bool)
        self.liftDescription = record.propertyForName(CloudFields.liftDescription.rawValue, defaultValue: "") as! String
        self.solo = NSNumber(bool: record.propertyForName(CloudFields.solo.rawValue, defaultValue: true) as! Bool)
        
        if let value = record.modelForName(CloudFields.organization.rawValue) as? OROrganization {
            self.organization = context.crossContextEquivalent(object: value) as? OROrganization
        }
        if let value = record.modelForName(CloudFields.creator.rawValue) as? ORAthlete {
            self.creator = value
        }
    }
    
}
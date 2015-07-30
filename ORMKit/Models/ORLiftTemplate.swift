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
        return super.model(type: ORLiftTemplate.self, record: record, context: context)
    }
    
    public class func templates(records records: [CKRecord], context: NSManagedObjectContext? = nil) -> [ORLiftTemplate] {
        return super.models(type: ORLiftTemplate.self, records: records, context: context)
    }
    @NSManaged public var defaultLift: NSNumber
    @NSManaged public var liftDescription: String
    @NSManaged public var liftName: String
    
    @NSManaged public var solo: NSNumber
    
    @NSManaged public var organization: OROrganization?
    
    @NSManaged public var creator: ORAthlete
    
    override func writeValuesFromRecord(record: CKRecord) {
        super.writeValuesFromRecord(record)
        
        guard let context = self.managedObjectContext else { return }
        
        self.liftName = record.propertyForName(Fields.liftName.rawValue, defaultValue: "")
        self.defaultLift = NSNumber(bool: record.propertyForName(Fields.defaultLift.rawValue, defaultValue: true))
        self.liftDescription = record.propertyForName(Fields.liftDescription.rawValue, defaultValue: "")
        self.solo = NSNumber(bool: record.propertyForName(Fields.solo.rawValue, defaultValue: true))
        
        if let value = record.modelForName(Fields.organization.rawValue) as? OROrganization {
            self.organization = context.crossContextEquivalent(object: value) as? OROrganization
        }
        if let value = record.modelForName(Fields.creator.rawValue) as? ORAthlete {
            self.creator = value
        }
    }
    
}
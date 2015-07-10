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
    public typealias SelfClass = ORLiftTemplate
    
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
    
    override public var record: CKRecord {
        get {
            let record = CKRecord(recordType: RecordType.ORLiftTemplate.rawValue, recordID: CKRecordID(recordName: recordName))
            return record
        }
        set {
            self.recordName = newValue.recordID.recordName
            self.liftName = newValue.propertyForName(CloudFields.liftName.rawValue, defaultValue: "") as! String
            self.defaultLift = newValue.propertyForName(CloudFields.defaultLift.rawValue, defaultValue: true) as! Bool
            self.liftDescription = newValue.propertyForName(CloudFields.liftDescription.rawValue, defaultValue: "") as! String
            self.solo = newValue.propertyForName(CloudFields.solo.rawValue, defaultValue: "") as! Bool
            
            self.organization = newValue.modelForName(CloudFields.organization.rawValue) as? OROrganization
            if let value = newValue.modelForName(CloudFields.creator.rawValue) as? ORAthlete {
                self.creator = value
            }
        }
    }
    
    public class func template(record: CKRecord? = nil) -> SelfClass {
        return super.model(type: SelfClass.self, record: record) as! SelfClass
    }
    
    public class func templates(#records: [CKRecord]) -> [SelfClass] {
        return super.models(type: SelfClass.self, records: records) as! [SelfClass]
    }
    @NSManaged public var defaultLift: Bool
    @NSManaged public var liftDescription: String
    @NSManaged public var liftName: String
    
    @NSManaged public var solo: Bool
    
    @NSManaged public var organization: OROrganization?
    
    @NSManaged public var creator: ORAthlete
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORLiftTemplate.recordType, predicate: NSPredicate(value: true))
        }
    }
    
}
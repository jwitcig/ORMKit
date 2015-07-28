//
//  ORMessage.swift
//  ORMKit
//
//  Created by Developer on 7/1/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

public class ORMessage: ORModel, ModelSubclassing {
    
    enum CloudFields: String {
        case title = "title"
        case body = "body"
        case createdDate = "createdDate"
        case organization = "organization"
        case creator = "creator"
    }
    enum LocalFields: String {
        case title = "title"
        case body = "body"
        case createdDate = "createdDate"
        case organization = "organization"
        case creator = "creator"
    }
    
    override public class var recordType: String { return RecordType.ORMessage.rawValue }
    
    public class func message(record: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> ORMessage {
        return super.model(type: ORMessage.self, record: record, context: context)
    }
    
    public class func messages(records records: [CKRecord], context: NSManagedObjectContext? = nil) -> [ORMessage] {
        return super.models(type: ORMessage.self, records: records, context: context) 
    }
    
    @NSManaged public var title: String
    @NSManaged public var body: String
    @NSManaged public var createdDate: NSDate
    @NSManaged public var organization: OROrganization?
    @NSManaged public var creator: ORAthlete
        
    override func writeValuesFromRecord(record: CKRecord) {
        super.writeValuesFromRecord(record)
        self.title = record.propertyForName(CloudFields.title.rawValue, defaultValue: "")
        self.body = record.propertyForName(CloudFields.body.rawValue, defaultValue: "")
        self.createdDate = record.propertyForName(CloudFields.createdDate.rawValue, defaultValue: NSDate()) 
        if let value = record.modelForName(CloudFields.organization.rawValue) as? OROrganization {
            self.organization = value
        }
        if let value = record.modelForName(CloudFields.creator.rawValue) as? ORAthlete {
            self.creator = value
        }
        
    }
    
}
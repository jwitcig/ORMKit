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
    public typealias SelfClass = ORMessage
    
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
    
    override public var record: CKRecord {
        get {
            let record = CKRecord(recordType: RecordType.ORMessage.rawValue, recordID: CKRecordID(recordName: recordName))
            return record
        }
        set {
            self.recordName = newValue.recordID.recordName
            self.title = newValue.propertyForName(CloudFields.title.rawValue, defaultValue: "") as! String
            self.body = newValue.propertyForName(CloudFields.body.rawValue, defaultValue: "") as! String
            self.createdDate = newValue.propertyForName(CloudFields.createdDate.rawValue, defaultValue: NSDate()) as! NSDate
            if let value = newValue.modelForName(CloudFields.organization.rawValue) as? OROrganization {
                self.organization = value
            }
            if let value = newValue.modelForName(CloudFields.creator.rawValue) as? ORAthlete {
                self.creator = value
            }

        }
    }
    
    override public class var recordType: String { return RecordType.ORMessage.rawValue }
    
    public class func message(record: CKRecord? = nil) -> SelfClass {
        return super.model(type: SelfClass.self, record: record) as! SelfClass
    }
    
    public class func messages(#records: [CKRecord]) -> [SelfClass] {
        return super.models(type: SelfClass.self, records: records) as! [SelfClass]
    }
    
    @NSManaged public var title: String
    @NSManaged public var body: String
    @NSManaged public var organization: OROrganization?
    @NSManaged public var creator: ORAthlete
    @NSManaged public var createdDate: NSDate
    
    public static func query(predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: ORMessage.recordType, predicate: filter)
        } else {
            return CKQuery(recordType: ORMessage.recordType, predicate: NSPredicate(value: true))
        }
    }
    
}
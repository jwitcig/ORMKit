//
//  ORMessage.swift
//  ORMKit
//
//  Created by Developer on 7/1/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif
import CloudKit
import CoreData

public class ORMessage: ORModel, ModelSubclassing {
    
    enum Fields: String {
        case title
        case body
        case createdDate
        case organization
        case creator
        
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

        self.title = record.propertyForName(Fields.title.rawValue, defaultValue: "")
        self.body = record.propertyForName(Fields.body.rawValue, defaultValue: "")
        self.createdDate = record.propertyForName(Fields.createdDate.rawValue, defaultValue: NSDate())
        
        guard let context = self.managedObjectContext else { return }

        if let value = record.modelForName(Fields.organization.rawValue) as? OROrganization {
            self.organization = context.crossContextEquivalent(object: value)
        }
        if let value = record.modelForName(Fields.creator.rawValue) as? ORAthlete {
            self.creator = context.crossContextEquivalent(object: value)
        }
        
    }
    
}
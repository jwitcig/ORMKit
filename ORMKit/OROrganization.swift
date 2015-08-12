//
//  OROrganization.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {
    
    func propertyForName<T>(name: String, defaultValue: T) -> T {
        guard let storedValue = self.valueForKey(name) as? T else { return defaultValue }
        return storedValue
    }
    
    func modelForName(name: String) -> ORModel? {
        guard let reference = self.valueForKey(name) as? CKReference else { return nil }
        return ORSession.currentSession.localData.fetchObject(id: reference.recordID.recordName, model: ORModel.self)
    }
    
    func modelListForName(name: String) -> [ORModel]? {
        guard let recordNames = ((self.valueForKey(name) as? [CKReference])?.recordIDs.recordNames) else {
            return nil
        }
        return ORSession.currentSession.localData.fetchObjects(ids: recordNames, model: ORModel.self)
    }

}

public class OROrganization: ORModel, ModelSubclassing {
    
    public enum Fields: String {
        case orgName
        case orgDescription
        case athletes
        case admins
        
        enum LocalOnly: String {
            case liftTemplates
            
            static var allCases: [LocalOnly] {
                return [liftTemplates]
            }
            
            static var allValues: [String] {
                return LocalOnly.allCases.map { $0.rawValue }
            }
        }
    }
    
    public class func organization(record record: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> OROrganization {
        return super.model(type: self, record: record, context: context)
    }
    
    public class func organizations(records records: [CKRecord], context: NSManagedObjectContext? = nil) -> [OROrganization] {
        return super.models(type: self, records: records, context: context)
    }

    @NSManaged public var messages: Set<ORMessage>
    @NSManaged public var orgDescription: String
    
    @NSManaged public var orgName: String
    
    @NSManaged public var liftTemplates: Set<ORLiftTemplate>
    @NSManaged public var athletes: Set<ORAthlete>
    @NSManaged public var admins: Set<ORAthlete>
    
    override public class var recordType: String { return RecordType.OROrganization.rawValue }
    
    override func writeValuesFromRecord(record: CKRecord) {
        super.writeValuesFromRecord(record)
        
        guard let context = self.managedObjectContext else { return }
        
        self.orgName = record.propertyForName(Fields.orgName.rawValue, defaultValue: "")
        self.orgDescription = record.propertyForName(Fields.orgDescription.rawValue, defaultValue: "")
        
        if let value = record.modelListForName(Fields.athletes.rawValue) as? [ORAthlete] {
            self.athletes = Set(context.crossContextEquivalents(objects: value))
        }
        if let value = record.modelListForName(Fields.admins.rawValue) as? [ORAthlete] {
            self.admins = Set(context.crossContextEquivalents(objects: value))
        }
    }
    
}


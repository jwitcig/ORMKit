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
    
    func propertyForName(name: String, defaultValue: AnyObject) -> AnyObject {
        if let value: AnyObject = self.valueForKey(name) {
            return value
        }
        return defaultValue
    }
    
    func modelForName(name: String) -> ORModel? {
        let localData = ORSession.currentSession.localData
        
        if let reference = self.valueForKey(name) as? CKReference {
            return localData.fetchObject(id: reference.recordID.recordName, model: ORModel.self)
        }
        return nil
    }
    
    func modelListForName(name: String) -> [ORModel]? {
        let localData = ORSession.currentSession.localData
        
        let recordNames = (self.valueForKey(name) as? [CKReference])?.map { $0.recordID.recordName }
        if let IDs = recordNames {
            return localData.fetchObjects(ids: IDs, model: ORModel.self)
        }
        return nil
    }

}

public class OROrganization: ORModel, ModelSubclassing {

    public enum CloudFields: String {
        case orgName = "orgName"
        case orgDescription = "description"
        case athletes = "athletes"
        case admins = "admins"
    }
    public enum LocalFields: String {
        case orgName = "orgName"
        case orgDescription = "orgDescription"
        case athletes = "athletes"
        case admins = "admins"
    }
    
    public class func organization(record record: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> OROrganization {
        return super.model(type: OROrganization.self, record: record, context: context) as! OROrganization
    }
    
    public class func organizations(records records: [CKRecord], context: NSManagedObjectContext? = nil) -> [OROrganization] {
        return super.models(type: OROrganization.self, records: records, context: context) as! [OROrganization]
    }

    @NSManaged public var messages: Set<ORMessage>
    @NSManaged public var orgDescription: String
    
    @NSManaged public var orgName: String
    
    @NSManaged public var liftTemplates: Set<ORLiftTemplate>
    @NSManaged public var athletes: Set<ORAthlete>
    @NSManaged public var admins: Set<ORAthlete>
    
    override public class var recordType: String { return RecordType.OROrganization.rawValue }
    
    public class func query(predicate: NSPredicate?) -> CKQuery {
        return super.query(OROrganization.recordType, predicate: predicate)
    }
    
    override func writeValuesFromRecord(record: CKRecord) {
        super.writeValuesFromRecord(record)
        
        guard let context = self.managedObjectContext else { return }
        
        self.orgName = record.propertyForName(LocalFields.orgName.rawValue, defaultValue: "") as! String
        self.orgDescription = record.propertyForName(LocalFields.orgDescription.rawValue, defaultValue: "") as! String
        
        if let value = record.modelListForName(LocalFields.athletes.rawValue) as? [ORAthlete] {
            self.athletes = Set(context.crossContextEquivalents(objects: value) as! [ORAthlete])
        }
        if let value = record.modelListForName(LocalFields.admins.rawValue) as? [ORAthlete] {
            self.admins = Set(context.crossContextEquivalents(objects: value) as! [ORAthlete])
        }
    }
    
}


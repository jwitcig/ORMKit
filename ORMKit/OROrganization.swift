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
        
        let recordNames = (self.valueForKey(name) as? [CKReference])?.map { $0.recordID.recordName! }
        if let IDs = recordNames {
            return localData.fetchObjects(ids: IDs, model: ORModel.self)
        }
        return nil
    }

}

public class OROrganization: ORModel, ModelSubclassing {
    public typealias SelfClass = OROrganization

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
    
    override public var record: CKRecord {
        get {
            let record = CKRecord(recordType: RecordType.OROrganization.rawValue, recordID: CKRecordID(recordName: recordName))
            return record
        }
        set {
            self.recordName = newValue.recordID.recordName
            self.orgName = newValue.propertyForName(LocalFields.orgName.rawValue, defaultValue: "") as! String
            self.orgDescription = newValue.propertyForName(LocalFields.orgDescription.rawValue, defaultValue: "") as! String
            
            if let value = newValue.modelListForName(LocalFields.orgName.rawValue) as? [ORLiftTemplate] {
                self.liftTemplates = Set(value)
            }
            if let value = newValue.modelListForName(LocalFields.athletes.rawValue) as? [ORAthlete] {
                self.athletes = Set(value)
            }
            if let value = newValue.modelListForName(LocalFields.admins.rawValue) as? [ORAthlete] {
                self.admins = Set(value)
            }
            
        }
    }
    
    public class func organization(record: CKRecord? = nil) -> SelfClass {
        return super.model(type: SelfClass.self, record: record) as! SelfClass
    }
    
    public class func organizations(#records: [CKRecord]) -> [SelfClass] {
        return super.models(type: SelfClass.self, records: records) as! [SelfClass]
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
    
}


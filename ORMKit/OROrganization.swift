//
//  OROrganization.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class OROrganization: ORModel, ModelSubclassing {
    
    public enum Fields: String {
        case orgName = "orgName"
        case description = "description"
        case athletes = "athletes"
        case admins = "admins"
    }
    public var description: String {
        get { return self.record.valueForKey(Fields.description.rawValue) as! String }
        set { self.record.setValue(newValue, forKey: Fields.description.rawValue) }
    }
    
    public var orgName: String {
        get { return self.record.valueForKey(Fields.orgName.rawValue) as! String }
        set { self.record.setValue(newValue, forKey: Fields.orgName.rawValue) }
    }
    
    public var athletes: [CKReference] {
        get {
            if let refs = self.record.valueForKey(Fields.athletes.rawValue) as? [CKReference] {
                return refs
            }
            return [CKReference]()
        }
        set { self.record.setValue(newValue, forKey: Fields.athletes.rawValue) }
    }
    public var admins: [CKReference] {
        get {
            if let refs = self.record.valueForKey(Fields.admins.rawValue) as? [CKReference] {
                return refs
            }
            return [CKReference]()
        }
        set { self.record.setValue(newValue, forKey: Fields.admins.rawValue) }
    }
    
    override public class var recordType: String { return RecordType.OROrganization.rawValue }
    
    required public init() {
        super.init(record: CKRecord(recordType: OROrganization.recordType))
    }

    required public init(record: CKRecord) {
        super.init(record: record)
    }
    
    public class func query(predicate: NSPredicate?) -> CKQuery {
        return super.query(OROrganization.recordType, predicate: predicate)
    }
    
}


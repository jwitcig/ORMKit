//
//  ORModel.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/11/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

protocol ModelSubclassing {
    static func query(predicate: NSPredicate?) -> CKQuery
}

enum RecordType: String {
    case OROrganization = "OROrganization"
    case ORLiftTemplate = "ORLiftTemplate"
    case ORLiftEntry = "ORLiftEntry"
    
    case ORMessage = "ORMessage"
    
    case ORAthlete = "ORAthlete"
}

public class ORModel: NSManagedObject {
    
    public var record: CKRecord {
        get {
            let record = CKRecord(recordType: "ORModel", recordID: CKRecordID(recordName: recordName))
            return record
        }
        set {
            self.recordName = newValue.recordID.recordName
            
//            for key in newValue.allKeys() as! [String] {
//                self.setValue(newValue.valueForKey(key), forKey: key)
//            }
        }
    }
    
    public var reference: CKReference {
        return CKReference(record: self.record, action: CKReferenceAction.None)
    }
    
    private class func defaultModel(#type: ORModel.Type) -> ORModel {
        let model = NSEntityDescription.insertNewObjectForEntityForName(type.recordType, inManagedObjectContext: ORSession.currentSession.localData.context) as! ORModel
        model.addRecord()
        return model
    }
    
    public func addRecord(record cloudRecord: CKRecord? = nil) {
        if let record = cloudRecord {
            self.record = record
        } else {
            self.record = CKRecord(recordType: ORModel.recordType)
        }
    }
    
    public class func model(#type: ORModel.Type, record cloudRecord: CKRecord? = nil) -> ORModel {
        var model = ORModel.defaultModel(type: type)
        
        if let record = cloudRecord {
            let storedModel = ORSession.currentSession.localData.fetchObject(id: record.recordID.recordName, model: type)
            
            if storedModel != nil {
                model = storedModel!
            }
            model.record = record
        }
        return model
    }
    
    public class func models(#type: ORModel.Type, records: [CKRecord]) -> [ORModel] {
        let recordNames = records.map { $0.recordID.recordName! }
        
        if let storedObjects = ORSession.currentSession.localData.fetchObjects(ids: recordNames, model: type) {
            let storedObjectsRecordNames = storedObjects.map { $0.recordName }
            
            let missingObjectRecords = records.filter { !contains(storedObjectsRecordNames, $0.recordID.recordName) }
            
            var models = storedObjects
            models += missingObjectRecords.map { ORModel.model(type: type, record: $0) }
            
            for model in models {
                let record = records.filter {
                    $0.recordID.recordName == model.recordName
                }.first
                
                if record != nil {
                    model.addRecord(record: record!)
                }
            }
            
            return models
        }
        return records.map { ORModel.model(type: type, record: $0) }
    }
    
    @NSManaged public var recordName: String
        
    class var recordType: String { return "ORModel" }
    
    public class func query(recordType: String, predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: recordType, predicate: filter)
        }
        return CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    }
    
    public static func references(#records: [CKRecord]) -> [CKReference] {
        var items = [CKReference]()
        for record in records {
            items.append(CKReference(record: record, action: CKReferenceAction.None))
        }
        return items
    }
    
    public static func references(#models: [ORModel]) -> [CKReference] {
        var items = [CKReference]()
        for model in models {
            items.append(CKReference(record: model.record, action: CKReferenceAction.None))
        }
        return items
    }
    
    private func readFromLocalRecord(localRecord: NSManagedObject) { }
    
    internal func writeToLocalRecord() -> NSManagedObject {
        return NSManagedObject()
    }
    
    internal func fetchLocalRecord(#type: ORModel.Type) -> NSManagedObject {
    
        let object = ORSession.currentSession.localData.fetchObject(id: self.recordName, model: type)
        if object != nil {
            return object!
        }
        return NSEntityDescription.insertNewObjectForEntityForName(
            type.recordType, inManagedObjectContext: ORSession.currentSession.localData.context) as! NSManagedObject
    }
    
}

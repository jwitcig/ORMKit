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
            var record: CKRecord!
            if let existingRecord = self.cloudRecord.record {
                 record = existingRecord
            } else {
                record = CKRecord(recordType: ORModel.recordType)
            }
            self.writeValuesToRecord(&record!)
            self.record = record
            return record
        }
        set {
            self.writeValuesFromRecord(newValue)
            self.cloudRecord.record = newValue
        }
    }
    
    public var recordName: String {
        get { return self.cloudRecord.recordName }
    }
    
    public var reference: CKReference {
        return CKReference(recordID: CKRecordID(recordName: self.recordName), action: CKReferenceAction.None)
    }
    
    @NSManaged public var cloudRecordDirty: Bool
    
    private class func defaultModel(type type: ORModel.Type, context: NSManagedObjectContext? = nil) -> ORModel {
        
        var managedObjectContext: NSManagedObjectContext!
        if context != nil {
            managedObjectContext = context!
        } else {
            managedObjectContext = ORSession.currentSession.localData.context
        }
        
        let model = NSEntityDescription.insertNewObjectForEntityForName(type.recordType, inManagedObjectContext: managedObjectContext) as! ORModel
        
        model.cloudRecord = NSEntityDescription.insertNewObjectForEntityForName(CloudRecord.recordType, inManagedObjectContext: managedObjectContext) as! CloudRecord
        
        model.record = CKRecord(recordType: type.recordType)
        return model
    }
    
    public class func model(type type: ORModel.Type, record cloudRecord: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> ORModel {
        var newModel: ORModel!
        
        if let record = cloudRecord {
            let model = ORModel.getOrCreateLocalRecord(record: record, type: type, context: context) as! ORModel
            
//            let storedModel = ORSession.currentSession.localData.fetchObject(id: record.recordID.recordName, model: type)
            
//            if storedModel != nil {
//                model = storedModel!
//            } else {
//                model = ORModel.defaultModel(type: type)
//            }
            
            model.record = record
            newModel = model
        } else {
            newModel = ORModel.defaultModel(type: type, context: context)
        }
        return newModel
    }
    
    public class func models(type type: ORModel.Type, records: [CKRecord], context: NSManagedObjectContext? = nil) -> [ORModel] {
        let recordNames = records.map { $0.recordID.recordName }
        
        if let storedObjects = ORSession.currentSession.localData.fetchObjects(ids: recordNames, model: type, context: context) {
            let storedObjectsRecordNames: [String] = storedObjects.map { $0.recordName }
            
            let missingObjectRecords = records.filter { !storedObjectsRecordNames.contains($0.recordID.recordName) }
            
            var models = storedObjects
            models += missingObjectRecords.map { ORModel.model(type: type, record: $0, context: context) }
            
            for model in models {
                let record = records.filter {
                    $0.recordID.recordName == model.recordName
                }.first
                
                if record != nil {
                    model.record = record!
                }
            }
            
            return models
        }
        return records.map { ORModel.model(type: type, record: $0, context: context) }
    }
    
    @NSManaged var cloudRecord: CloudRecord
        
    class var recordType: String { return "ORModel" }
    
    public class func query(recordType: String, predicate: NSPredicate?) -> CKQuery {
        if let filter = predicate {
            return CKQuery(recordType: recordType, predicate: filter)
        }
        return CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    }
    
    public static func references(records records: [CKRecord]) -> [CKReference] {
        var items = [CKReference]()
        for record in records {
            items.append(CKReference(record: record, action: CKReferenceAction.None))
        }
        return items
    }
    
    public static func references(models models: [ORModel]) -> [CKReference] {
        var items = [CKReference]()
        for model in models {
            items.append(CKReference(record: model.record, action: CKReferenceAction.None))
        }
        return items
    }
    
    func writeValuesFromRecord(record: CKRecord) { }
    
    func writeValuesToRecord(inout record: CKRecord) {
        record.setValuesForKeysWithDictionary(self.changedKeysForCloudKit)
    }
    
    public func updateRecord() {
        _  = self.record
    }

    internal class
        func getOrCreateLocalRecord(record record: CKRecord, type: ORModel.Type, context: NSManagedObjectContext? = nil) -> NSManagedObject {
            guard let object = ORSession.currentSession.localData.fetchObject(id: record.recordID.recordName, model: type, context: context) else {
            
            let model = ORModel.defaultModel(type: type, context: context)
            model.record = record
            return model
        }
        return object
    }
    
}

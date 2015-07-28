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
    func writeValuesFromRecord(record: CKRecord)
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
        
        let managedObjectContext = context != nil ? context! : ORSession.currentSession.localData.context
        
        let model = NSEntityDescription.insertNewObjectForEntityForName(type.recordType, inManagedObjectContext: managedObjectContext) as! ORModel
        
        model.cloudRecord = NSEntityDescription.insertNewObjectForEntityForName(CloudRecord.recordType, inManagedObjectContext: managedObjectContext) as! CloudRecord
        
        model.record = CKRecord(recordType: type.recordType)
        return model
    }
    
    public class func model<T>(type type: T.Type, record cloudRecord: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> T {
        
        guard let record = cloudRecord else {
            return ORModel.defaultModel(type: type as! ORModel.Type, context: context) as! T
        }
        let model = ORModel.getOrCreateLocalRecord(record: record, type: type as! ORModel.Type, context: context) as! ORModel
        model.record = record
        return model as! T
    }
    
    public class func models<T>(type type: T.Type, records: [CKRecord], context: NSManagedObjectContext? = nil) -> [T] {

        guard let storedObjects = ORSession.currentSession.localData.fetchObjects(
                    ids: records.recordNames,
                    model: type as! ORModel.Type,
                    context: context)
            where storedObjects.count > 0 else {
            return records.map { ORModel.model(type: type as! ORModel.Type, record: $0, context: context) as! T }
        }
        
        let storedObjectsRecordNames: [String] = storedObjects.recordNames
        
        let missingObjectRecords = records.filter { !storedObjectsRecordNames.contains($0.recordID.recordName) }
        
        storedObjects.map { model in
            model.record = records.filter { $0.recordID.recordName == model.recordName }.first!
        }
        
        var models = storedObjects
        models += missingObjectRecords.map {
            ORModel.model(type: type as! ORModel.Type, record: $0, context: context)
        }
        return models.map { $0 as! T }
    }
    
    @NSManaged var cloudRecord: CloudRecord
        
    class var recordType: String { return "ORModel" }
    
    public class func query(recordType: String, predicate: NSPredicate?) -> CKQuery {
        guard let filter = predicate else {
            return CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        }
        return CKQuery(recordType: recordType, predicate: filter)
    }
    
    func writeValuesFromRecord(record: CKRecord) { }
    
    func writeValuesToRecord(inout record: CKRecord) {
        record.setValuesForKeysWithDictionary(self.changedKeysForCloudKit)
    }
    
    public func updateRecord() { _ = self.record }

    internal class func getOrCreateLocalRecord(record record: CKRecord, type: ORModel.Type, context: NSManagedObjectContext? = nil) -> NSManagedObject {
            
        guard let object = ORSession.currentSession.localData.fetchObject(id: record.recordID.recordName, model: type, context: context) else {
            
            let model = ORModel.defaultModel(type: type, context: context)
            model.record = record
            return model
        }
        return object
    }
    
}

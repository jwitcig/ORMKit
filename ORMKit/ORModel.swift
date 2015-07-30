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
    case OROrganization
    case ORLiftTemplate
    case ORLiftEntry
    
    case ORMessage
    
    case ORAthlete
}

public class ORModel: NSManagedObject {
    
    static var LocalOnlyFields = [
        OROrganization.recordType: OROrganization.Fields.LocalOnly.allValues,
        ORLiftTemplate.recordType: ORLiftTemplate.Fields.LocalOnly.allValues,
        ORLiftEntry.recordType: ORLiftEntry.Fields.LocalOnly.allValues,
        ORMessage.recordType: ORMessage.Fields.LocalOnly.allValues,
        ORAthlete.recordType: ORAthlete.Fields.LocalOnly.allValues,
    ]
    
    public var record: CKRecord {
        get {
            var record: CKRecord!
            if let existingRecord = self.cloudRecord.record {
                 record = existingRecord
            } else {
                record = CKRecord(recordType: ORModel.recordType)
            }
            self.writeValuesToRecord(&record!)
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
    public var cloudUpdateSinceSave = false
    
    private class func defaultModel(type type: ORModel.Type, context: NSManagedObjectContext? = nil) -> ORModel {
        
        let managedObjectContext = context != nil ? context! : ORSession.currentSession.localData.context
        
        let model = NSEntityDescription.insertNewObjectForEntityForName(type.recordType, inManagedObjectContext: managedObjectContext) as! ORModel
        
        model.cloudRecord = NSEntityDescription.insertNewObjectForEntityForName(CloudRecord.recordType, inManagedObjectContext: managedObjectContext) as! CloudRecord
        
        model.record = CKRecord(recordType: type.recordType)
        return model
    }
    
    internal func updateFromCloudRecord(record: CKRecord) {
        self.record = record
        self.cloudUpdateSinceSave = true
    }
    
    public class func model<T>(type type: T.Type, record cloudRecord: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> T {
        
        guard let record = cloudRecord else {
            return ORModel.defaultModel(type: type as! ORModel.Type, context: context) as! T
        }
        let model = ORModel.getOrCreateLocalRecord(record: record, type: type as! ORModel.Type, context: context) as! ORModel
        model.updateFromCloudRecord(record)
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
            model.updateFromCloudRecord( records.filter { $0.recordID.recordName == model.recordName }.first! )
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
        var newDataDict = [String: AnyObject]()
        
        var keys = self.entity.attributeKeys
        keys += self.entity.relationshipsByName.keys.array
        
        
        var rejectKeys = ["cloudRecordDirty"]
        if let entityName = self.entity.name {
            if let entityRejectKeys = ORModel.LocalOnlyFields[entityName] {
                rejectKeys += entityRejectKeys
            }
        }
        
        let filteredKeys = keys.filter { !rejectKeys.contains($0) }
        
        for key in filteredKeys {
            let value = self.valueForKey(key)
            
            guard value as? CloudRecord == nil else { continue }
            
            guard value as? ORModel == nil else {
                let newModel = value as! ORModel
                
                guard let existingModel = newDataDict[key] as? ORModel
                    where newModel.recordName == existingModel.recordName else {
                        newDataDict[key] = newModel.reference
                        continue
                }
                continue
            }
            
            guard value as? Set<ORModel> == nil else {
                newDataDict[key] = (value as! Set<ORModel>).references
                continue
            }
            
            newDataDict[key] = value
        }

        record.setValuesForKeysWithDictionary(newDataDict)
    }
    
    public func updateRecord() { _ = self.record }

    internal class func getOrCreateLocalRecord(record record: CKRecord, type: ORModel.Type, context: NSManagedObjectContext? = nil) -> NSManagedObject {
            
        guard let object = ORSession.currentSession.localData.fetchObject(id: record.recordID.recordName, model: type, context: context) else {
            
            let model = ORModel.defaultModel(type: type, context: context)
            model.updateFromCloudRecord(record)
            return model
        }
        return object
    }
    
}

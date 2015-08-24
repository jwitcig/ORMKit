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
        return CKReference(recordID: CKRecordID(recordName: self.recordName), action: .None)
    }
    
    @NSManaged public var cloudRecordDirty: Bool
    public var cloudUpdateSinceSave = false
    
    private class func defaultModel(type type: ORModel.Type, context: NSManagedObjectContext? = nil, insertIntoManagedObjectContext: Bool? = true) -> ORModel {
        
        let managedObjectContext = context != nil ? context! : ORSession.currentSession.localData.context

        var model: ORModel!
        
        if insertIntoManagedObjectContext == true {
            model = NSEntityDescription.insertNewObjectForEntityForName(type.recordType, inManagedObjectContext: managedObjectContext) as! ORModel
            
            model.cloudRecord = NSEntityDescription.insertNewObjectForEntityForName(CloudRecord.recordType, inManagedObjectContext: managedObjectContext) as! CloudRecord
        } else {
            let modelEntityDescription = NSEntityDescription.entityForName(type.recordType, inManagedObjectContext: managedObjectContext)!
            model = NSManagedObject(entity: modelEntityDescription, insertIntoManagedObjectContext: nil) as! ORModel
            
            let cloudRecordEntityDescription = NSEntityDescription.entityForName(CloudRecord.recordType, inManagedObjectContext: managedObjectContext)!
            model.cloudRecord = NSManagedObject(entity: cloudRecordEntityDescription, insertIntoManagedObjectContext: nil) as! CloudRecord
        }
        
        model.record = CKRecord(recordType: type.recordType)
        return model
    }
    
    internal func updateFromCloudRecord(record: CKRecord) {
        self.record = record
        self.cloudUpdateSinceSave = true
    }
    
    public class func model<T: ORModel>(type type: T.Type, record cloudRecord: CKRecord? = nil, context: NSManagedObjectContext? = nil, insertIntoManagedObjectContext insert: Bool = true) -> T {
        
        guard let record = cloudRecord else {
            return ORModel.defaultModel(type: type, context: context, insertIntoManagedObjectContext: insert) as! T
        }
        return ORModel.getOrCreateLocalRecord(record: record, type: type, context: context, insertIntoManagedObjectContext: insert) as! T
    }
    
    public class func models<T: ORModel>(type type: T.Type, records: [CKRecord], context: NSManagedObjectContext? = nil, insertIntoManagedObjectContext insert: Bool = true) -> [T] {
        
        guard insert == true else {
            return records.map { ORModel.model(type: type, record: $0, context: context, insertIntoManagedObjectContext: insert)}
        }
        
        guard let storedObjects = ORSession.currentSession.localData.fetchObjects(
                    ids: records.recordIDs.recordNames,
                    model: type,
                    context: context)
            where storedObjects.count > 0 else {
                return records.map { ORModel.model(type: type, record: $0, context: context) }
        }

        let storedObjectsRecordNames: [String] = storedObjects.recordNames
        
        let missingObjectRecords = records.filter { !storedObjectsRecordNames.contains($0.recordID.recordName) }
        
        storedObjects.map { model in
            model.updateFromCloudRecord( records.filter { $0.recordID.recordName == model.recordName }.first! )
        }
        
        var models = storedObjects
        models += missingObjectRecords.map {
            ORModel.model(type: type, record: $0, context: context)
        }
        return models.map { $0 }
    }
    
    @NSManaged public var cloudRecord: CloudRecord
        
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

    internal class func getOrCreateLocalRecord(record record: CKRecord, type: ORModel.Type, context: NSManagedObjectContext? = nil, insertIntoManagedObjectContext insert: Bool = true) -> NSManagedObject {
        
        guard insert == true else {
            let model = ORModel.defaultModel(type: type, context: context, insertIntoManagedObjectContext: insert)
            model.updateFromCloudRecord(record)
            return model
        }
        
        guard let object = ORSession.currentSession.localData.fetchObject(id: record.recordID.recordName, model: type, context: context) else {
            
            let model = ORModel.defaultModel(type: type, context: context)
            model.updateFromCloudRecord(record)
            return model
        }
        object.updateFromCloudRecord(record)
        return object
    }
    
}

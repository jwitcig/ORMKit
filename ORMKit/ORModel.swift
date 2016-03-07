//
//  ORModel.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/11/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif
import CloudKit
import CoreData

protocol ModelSubclassing {

}

enum RecordType: String {
    case OROrganization
    case ORLiftTemplate
    case ORLiftEntry
    
    case ORMessage
    
    case ORAthlete
}

public class ORModel: NSManagedObject {
    
    @NSManaged public var createdDate: NSDate!
    @NSManaged public var lastLocalSaveDate: NSDate!
    @NSManaged public var lastCloudSaveDate: NSDate!
    
    @NSManaged var cloudRecord: CloudRecord
    
    public var record: CKRecord {
        get {
            var record: CKRecord!
            if let existingRecord = cloudRecord.record {
                record = existingRecord
            } else {
                record = CKRecord(recordType: ORModel.recordType)
            }
            writeValuesToRecord(&record!)
            return record
        }
        set {
            writeValuesFromRecord(newValue)
            cloudRecord.record = newValue
        }
    }
    
    public var recordName: String {
        get { return self.cloudRecord.recordName }
    }
    
    public var reference: CKReference {
        return CKReference(recordID: CKRecordID(recordName: self.recordName), action: CKReferenceAction.None)
    }
    
    static var LocalOnlyFields = [
        ORLiftTemplate.recordType: ORLiftTemplate.Fields.LocalOnly.allValues,
        ORLiftEntry.recordType: ORLiftEntry.Fields.LocalOnly.allValues,
        ORAthlete.recordType: ORAthlete.Fields.LocalOnly.allValues,
    ]
    
    class func modelType(recordType recordType: String) -> ORModel.Type {
        switch recordType {
        case ORModel.recordType:
            return ORModel.self
        case RecordType.ORAthlete.rawValue:
            return ORAthlete.self
        case RecordType.ORLiftTemplate.rawValue:
            return ORLiftTemplate.self
        case RecordType.ORLiftEntry.rawValue:
            return ORLiftEntry.self
        default:
            return ORModel.self
        }
    }
    
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
        
        model.createdDate = NSDate()
        
        model.record = CKRecord(recordType: type.recordType)
        
        return model
    }
    
    public class func model<T: ORModel>(type type: T.Type, context: NSManagedObjectContext? = nil, insertIntoManagedObjectContext insert: Bool = true) -> T {
        
        return ORModel.defaultModel(type: type, context: context, insertIntoManagedObjectContext: insert) as! T
    }
    
    public class func model<T: ORModel>(type type: T.Type, record: CKRecord?, context: NSManagedObjectContext? = nil, insertIntoManagedObjectContext insert: Bool = true) -> T {
        
        guard let cloudRecord = record else {
            return ORModel.defaultModel(type: type, context: context) as! T
        }
        let model = ORModel.getOrCreateLocalRecord(record: cloudRecord, type: type, context: context)
        return model as! T
    }
    
    public class func models<T>(type type: T.Type, records: [CKRecord], context: NSManagedObjectContext? = nil) -> [T] {
        guard let storedObjects = ORSession.currentSession.localData.fetchObjects(
            ids: records.recordIDs.recordNames,
            model: type as! ORModel.Type,
            context: context)
            where storedObjects.count > 0 else {
                return records.map { ORModel.model(type: type as! ORModel.Type, record: $0, context: context) as! T }
        }
        
        let storedObjectsRecordNames: [String] = storedObjects.recordNames
        
        let missingObjectRecords = records.filter { !storedObjectsRecordNames.contains($0.recordID.recordName) }
        
        storedObjects.forEach { model in
            model.updateFromCloudRecord( records.filter { $0.recordID.recordName == model.recordName }.first! )
        }
        
        var models = storedObjects
        models += missingObjectRecords.map {
            ORModel.model(type: type as! ORModel.Type, record: $0, context: context)
        }
        return models.map { $0 as! T }
    }
    
    internal func updateFromCloudRecord(record: CKRecord) {
        self.record = record
    }
    
    func writeValuesFromRecord(record: CKRecord) {
        record.allKeys().forEach {
            
            guard let context = self.managedObjectContext else { return }
        
            guard let _ = record[$0] as? CKReference else {
                setValue(record[$0], forKey: $0)
                return
            }
            
            if let value = record.modelForName($0) {
                setValue(context.crossContextEquivalent(object: value), forKey: $0)
            }
            
        }
    }
    
    func writeValuesToRecord(inout record: CKRecord) {
        var newDataDict = [String: AnyObject]()
        
        var keys = Array(entity.attributesByName.keys)
        keys += self.entity.relationshipsByName.keys
        
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
    
    internal class func getOrCreateLocalRecord(record record: CKRecord, type: ORModel.Type, context: NSManagedObjectContext? = nil) -> NSManagedObject {
        
        guard let object = ORSession.currentSession.localData.fetchObject(id: record.recordID.recordName, model: type, context: context) else {
            
            let model = ORModel.defaultModel(type: type, context: context)
            model.updateFromCloudRecord(record)
            return model
        }
        return object
    }
    
    class var recordType: String { return "ORModel" }
    
}

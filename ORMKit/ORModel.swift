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
    
    private class func defaultModel(type type: ORModel.Type, context: NSManagedObjectContext? = nil, insertIntoManagedObjectContext: Bool? = true) -> ORModel {
        
        let managedObjectContext = context != nil ? context! : ORSession.currentSession.localData.context

        var model: ORModel!
        
        if insertIntoManagedObjectContext == true {
            model = NSEntityDescription.insertNewObjectForEntityForName(type.recordType, inManagedObjectContext: managedObjectContext) as! ORModel
            
        } else {
            let modelEntityDescription = NSEntityDescription.entityForName(type.recordType, inManagedObjectContext: managedObjectContext)!
            model = NSManagedObject(entity: modelEntityDescription, insertIntoManagedObjectContext: nil) as! ORModel
        }
        
        return model
    }
    
    public class func model<T: ORModel>(type type: T.Type, context: NSManagedObjectContext? = nil, insertIntoManagedObjectContext insert: Bool = true) -> T {
        
        return ORModel.defaultModel(type: type, context: context, insertIntoManagedObjectContext: insert) as! T
    }
    
    public class func model<T: ORModel>(type type: T.Type, record: CKRecord, context: NSManagedObjectContext? = nil, insertIntoManagedObjectContext insert: Bool = true) -> T {
        let model = ORModel.defaultModel(type: type)
        model.record = record
        
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
    
    func writeValuesFromRecord(record: CKRecord) { }
    
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
    
    
    class var recordType: String { return "ORModel" }
    
}

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
import CoreData

import SwiftTools

protocol ModelSubclassing {

}

enum RecordType: String {
    case OROrganization
    case ORLiftTemplate
    case ORLiftEntry
    
    case ORMessage
    
    case ORAthlete
}

public protocol ORLocalModel {
    var lastLocalSaveDate: NSDate! { get set }

}

public protocol ORCloudModel {
    var lastCloudSaveDate: NSDate! { get set }
}

public class ORModel: NSObject, ORLocalModel, ORCloudModel {
    
    public var createdDate: NSDate!
    public var lastLocalSaveDate: NSDate!
    public var lastCloudSaveDate: NSDate!
    
    var keys: [String] {
        return ["createdDate", "lastLocalSaveDate", "lastCloudSaveDate"]
    }
    
    class var entityName: String { return "ORModel" }
    var entityName: String { return "ORModel" }
    
    public var id: String = NSUUID().UUIDString
    
//    static var LocalOnlyFields = [
//        ORLiftTemplate.recordType: ORLiftTemplate.Fields.LocalOnly.allValues,
//        ORLiftEntry.recordType: ORLiftEntry.Fields.LocalOnly.allValues,
//        ORAthlete.recordType: ORAthlete.Fields.LocalOnly.allValues,
//    ]
//    
//    class func modelType(recordType recordType: String) -> ORModel.Type {
//        switch recordType {
//        case ORModel.recordType:
//            return ORModel.self
//        case RecordType.ORAthlete.rawValue:
//            return ORAthlete.self
//        case RecordType.ORLiftTemplate.rawValue:
//            return ORLiftTemplate.self
//        case RecordType.ORLiftEntry.rawValue:
//            return ORLiftEntry.self
//        default:
//            return ORModel.self
//        }
//    }
    
    public required override init() {
        super.init()
        
        self.createdDate = NSDate()
    }
    
    public required init(id: String) {
        super.init()
       
        self.id = id
        
        pullFromLocalRecord()
    }
    
    public required init(dictionary: [String: AnyObject]) {
        super.init()
        self.setValuesForKeysWithDictionary(dictionary)
    }
    
    static func multiple<T: ORModel>(dictionaries dictionaries: [[String: AnyObject]], type: T.Type) -> [T] {
        return dictionaries.map { T.init(dictionary: $0) }
    }
    
    var dictionaryRepresentation: NSDictionary {
        var dictionaryRepresentation = [String: AnyObject]()
        
        keys.forEach {
            let value = valueForKey($0)
            var treatedValue = value
            
            if let date = value as? NSDate {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                treatedValue = dateFormatter.stringFromDate(date)
            }
            
            dictionaryRepresentation[$0] = treatedValue
        }
        return dictionaryRepresentation
    }
    
    var _localRecord: NSManagedObject?
    var localRecord: NSManagedObject {
        guard _localRecord == nil else { return _localRecord! }
        
        let context = NSManagedObjectContext.contextForCurrentThread()
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(key: "id", comparator: .Equals, value: id)
        
        var managedObject: NSManagedObject?
        do {
            managedObject = try context.executeFetchRequest(fetchRequest).first as? NSManagedObject
        } catch let error as NSError {
            print(error)
        }
        
        guard managedObject == nil else {
            return managedObject!
        }
        
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
    }
    
    func pullFromLocalRecord() {
        let keys = Array(localRecord.entity.attributesByName.keys)
        let localRecordDictionary = localRecord.dictionaryWithValuesForKeys(keys)
        
        setValuesForKeysWithDictionary(localRecordDictionary)
    }
}

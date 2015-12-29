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
        
    class var recordType: String { return "ORModel" }
    
}

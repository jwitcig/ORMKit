//
//  OROrganization.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif
import CloudKit
import CoreData

extension CKRecord {
    
    func propertyForName<T>(name: String, defaultValue: T) -> T {
        guard let storedValue = self.valueForKey(name) as? T else { return defaultValue }
        return storedValue
    }
    
    func modelForName(name: String) -> ORModel? {
        guard let reference = self.valueForKey(name) as? CKReference else { return nil }
        return self.modelFromReference(reference)
    }
    
    func modelListForName(name: String) -> [ORModel]? {
        guard let references = self.valueForKey(name) as? [CKReference] else { return nil }
        return self.modelListFromReferences(references)
    }
    
    func modelFromReference(reference: CKReference) -> ORModel? {
        return ORSession.currentSession.localData.fetchObject(id: reference.recordID.recordName, model: ORModel.self)
    }
    
    func modelListFromReferences(references: [CKReference]) -> [ORModel]? {
        let recordNames = references.recordIDs.recordNames
        return ORSession.currentSession.localData.fetchObjects(ids: recordNames, model: ORModel.self, context: NSManagedObjectContext.contextForCurrentThread())
    }
    
    func referenceForName(name: String) -> CKReference? {
        return self[name] as? CKReference
    }
    
    func referencesForName(name: String) -> Set<CKReference> {
        let references = self[name] as? [CKReference]
        return references != nil ? Set(references!) : Set()
    }

}

public class OROrganization: ORModel, ModelSubclassing {
    
    public enum Fields: String {
        case orgName
        case orgDescription
        case athletes
        case admins
        
        enum LocalOnly: String {
            case liftTemplates
            
            static var allCases: [LocalOnly] {
                return [liftTemplates]
            }
            
            static var allValues: [String] {
                return LocalOnly.allCases.map { $0.rawValue }
            }
        }
    }
    
    public class func organization(record record: CKRecord? = nil, context: NSManagedObjectContext? = nil) -> OROrganization {
        return super.model(type: self, record: record, context: context)
    }
    
    public class func organizations(records records: [CKRecord], context: NSManagedObjectContext? = nil) -> [OROrganization] {
        return super.models(type: self, records: records, context: context)
    }

    @NSManaged public var messages: Set<ORMessage>
    @NSManaged public var orgDescription: String
    
    @NSManaged public var orgName: String
    
    @NSManaged public var liftTemplates: Set<ORLiftTemplate>
    @NSManaged public var athletes: Set<ORAthlete>
    @NSManaged public var admins: Set<ORAthlete>
    
    public var athleteReferences: Set<CKReference>?
    var adminReferences: Set<CKReference>?
    
    override public class var recordType: String { return RecordType.OROrganization.rawValue }
    
    override func writeValuesFromRecord(record: CKRecord) {
        super.writeValuesFromRecord(record)
        
        self.orgName = record.propertyForName(Fields.orgName.rawValue, defaultValue: "")
        self.orgDescription = record.propertyForName(Fields.orgDescription.rawValue, defaultValue: "")
        
        self.athleteReferences = record.referencesForName(Fields.athletes.rawValue)
        self.adminReferences = record.referencesForName(Fields.admins.rawValue)
        
        guard let context = self.managedObjectContext else { return }
        
        if let references = self.athleteReferences,
            let models = record.modelListFromReferences(Array(references)) as? [ORAthlete] {
                self.athletes = Set(context.crossContextEquivalents(objects: models))
        }
        
        if let references = self.adminReferences,
            let models = record.modelListFromReferences(Array(references)) as? [ORAthlete] {
                self.admins = Set(context.crossContextEquivalents(objects: models))
        }
    }
    
}


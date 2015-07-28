//
//  ORMSession.swift
//  ORMKit
//
//  Created by Application Development on 6/13/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

public class ORSession {
    
    public static var currentSession = ORSession()
    
    public var soloSession: Bool { return self.currentOrganization == nil }
    public var currentAthleteId: CKRecordID?
    public var currentAthlete: ORAthlete?
    public var currentOrganization: OROrganization?
    
    private var _localData: ORLocalData!
    public var localData: ORLocalData! {
        get { return _localData }
        set {
            self._localData = newValue
            self._localData.session = self
        }
    }
    
    private var _cloudData: ORCloudData!
    public var cloudData: ORCloudData! {
        get { return _cloudData }
        set {
            _cloudData = newValue
            _cloudData.session = self
        }
    }
    
    private var _soloStats: ORSoloStats!
    public var soloStats: ORSoloStats {
        get { return _soloStats }
        set {
            _soloStats = newValue
            _soloStats.session = self
        }
    }
    
    public static let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(NSBundle.allBundles())
    public static let persistentStoreCooridnator = NSPersistentStoreCoordinator(managedObjectModel: ORSession.managedObjectModel!)

    public var managedObjectContext: NSManagedObjectContext!
    
    public init() { }
    
    public func signInWithCloud(completionHandler completionHandler: ((Bool, NSError?)->())?) {
        self.cloudData.container.fetchUserRecordIDWithCompletionHandler { (recordID, error) -> Void in
            guard error == nil else { print(error); return }
            
            let query = CKQuery(recordType: ORAthlete.recordType, predicate: NSPredicate(key: "userRecordName", comparator: .Equals, value: recordID!.recordName))
            
            CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
                
                var success = false
                defer { completionHandler?(success, error) }
                
                guard error == nil else { return }
                
                let context = NSManagedObjectContext.contextForCurrentThread()
                var athlete: ORAthlete!
                defer {
                    ORAthlete.setCurrentAthlete(athlete)
                    self.localData.save(context: context)
                    success = true
                }
                
                guard let userRecords = results
                    where userRecords.count > 0 else {
                        athlete = ORAthlete.athlete(record: CKRecord(recordType: ORAthlete.recordType))
                        return
                }
                
                let record = userRecords.first!
                
                guard let fetchedAthlete = self.localData.fetchObject(id: record.recordID.recordName, model: ORAthlete.self, context: context) as? ORAthlete else {
                    athlete = ORAthlete.athlete(record: record, context: context)
                    return
                }
                athlete = fetchedAthlete
                
            }
        }
    }
    
    public func signInLocally() -> (Bool, ORAthlete?) {
        let context = NSManagedObjectContext.contextForCurrentThread()
        
        let currentUserRecordName = NSUserDefaults.standardUserDefaults().objectForKey("currentUserRecordName") as? String
        if let recordName = currentUserRecordName {
            
            let request = NSFetchRequest(entityName: ORAthlete.recordType)
            request.predicate = NSPredicate(format: "%K == %@", "recordName", recordName)
            let results: [AnyObject]?
            do {
                results = try context.executeFetchRequest(request)
            } catch _ {
                results = nil
            }
            
            if let athlete = results?.first as? ORAthlete {
                ORAthlete.setCurrentAthlete(athlete)
                return (true, athlete)
            }
        }
        return (false, nil)
    }
    
}

internal protocol DataConvenience {
    init(session: ORSession, dataManager: ORDataManager)
    var dataManager: ORDataManager { get set }
    
    var session: ORSession { get set }
}
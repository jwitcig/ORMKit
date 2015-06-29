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
    
    public static let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(NSBundle.allBundles())
    public static let persistentStoreCooridnator = NSPersistentStoreCoordinator(managedObjectModel: ORSession.managedObjectModel!)

    public var managedObjectContext: NSManagedObjectContext!
    
    public init() {
        
    }
    
    public func signInWithCloud(#completionHandler: ((Bool, NSError?)->())?) {
        var context = self.localData.context
        self.cloudData.container.fetchUserRecordIDWithCompletionHandler({ (recordId, error) -> Void in
            
            if error == nil {
                let query: CKQuery = ORAthlete.query(NSPredicate(format: "%K == %@", "userRecordName", recordId.recordName))
                
                CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (results, error) -> Void in
                    
                    var success = false
                    if error == nil {
                        if results.count == 1 {
                            
                            var athlete = ORAthlete(record: results.first! as! CKRecord)
                            
                            ORAthlete.setCurrentAthlete(athlete)
                            success = true                            
                        }
                    } else {
                        println(error)
                    }
                    
                    if let handler = completionHandler {
                        handler(success, error)
                    }
                    
                })
            } else {
                println(error)
            }
        })
    }
    
    public func signInLocally() -> (Bool, ORAthlete?) {
        let context = localData.context
        
        let currentUserRecordName = NSUserDefaults.standardUserDefaults().objectForKey("currentUserRecordName") as? String
        if let recordName = currentUserRecordName {
            
            var request = NSFetchRequest(entityName: ORAthlete.recordType)
            request.predicate = NSPredicate(format: "%K == %@", "recordName", recordName)
            let results = context.executeFetchRequest(request, error: nil)
            
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
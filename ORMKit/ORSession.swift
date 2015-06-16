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
    
    public static let currentSession = ORSession()
    
    public var currentAthleteId: CKRecordID?
    public var currentAthlete: ORAthlete?
    
//    public var setCurrentUser(recordId: C)
    
    public static let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(NSBundle.allBundles())
    public static let persistentStoreCooridnator = NSPersistentStoreCoordinator(managedObjectModel: ORSession.managedObjectModel!)

    public var managedObjectContext: NSManagedObjectContext!
    
}
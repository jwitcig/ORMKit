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
    
    public var currentUserId: CKRecordID?
    public var currentUser: ORUser? {
//        if let userId = self.currentUserId {
//            var user = ORUser(context: ORSession.managedObjectContext)
//            user.record = CKRecord(recordType: ORUser.recordType, recordID: userId)
//            return user
//        }
        return nil
    }
    
    public static let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(NSBundle.allBundles())
    public static let persistentStoreCooridnator = NSPersistentStoreCoordinator(managedObjectModel: ORSession.managedObjectModel!)

    public var managedObjectContext: NSManagedObjectContext!
    
    
}
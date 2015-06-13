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
        return ORUser(record: CKRecord(recordType: ORUser.recordType, recordID: self.currentUserId))
    }
    
}
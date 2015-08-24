//
//  CloudRecord.swift
//  ORMKit
//
//  Created by Developer on 7/22/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import CloudKit

public class CloudRecord: NSManagedObject {
    
    static let recordType = "CloudRecord"
    
    @NSManaged var recordName: String
    @NSManaged var recordData: NSData
    
    @NSManaged var model: ORModel?
        
    var record: CKRecord? {
        get {
            let archivedData = NSData(data: self.recordData)
            let coder = NSKeyedUnarchiver(forReadingWithData: archivedData)
            let record = CKRecord(coder: coder)!
            coder.finishDecoding()
            return record
        }
        set {
            let archivedData = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: archivedData)
            newValue!.encodeSystemFieldsWithCoder(archiver)
            archiver.finishEncoding()            
            self.recordName = newValue!.recordID.recordName
            self.recordData = NSData(data: archivedData)
        }
    }
    
}

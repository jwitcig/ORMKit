//
//  ORCloudResponse.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation
import CloudKit

public class ORCloudDataResponse: ORDataResponse {
    
    public var objects: [CKRecord] {
        return self.dataObjects as! [CKRecord]
    }
    
    public var object: CKRecord? {
        return self.dataObject as? CKRecord
    }
    
}
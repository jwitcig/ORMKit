//
//  ORLocalDataResponse.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation

public class ORLocalDataResponse: ORDataResponse {
    
    public var objects: [ORModel] {
        return self.dataObjects as! [ORModel]
    }
    
    public var object: ORModel? {
        return self.dataObject as? ORModel
    }
    
}
//
//  ORLocalDataResponse.swift
//  ORMKit
//
//  Created by Developer on 6/16/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation

public class ORLocalDataResponse: ORDataResponse {

    public var localResults: [ORModel] {
        return self.results as! [ORModel]
    }
    
}
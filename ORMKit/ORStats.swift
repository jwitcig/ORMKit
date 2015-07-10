//
//  ORStats.swift
//  ORMKit
//
//  Created by Developer on 7/5/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation

class ORStats {
    
    var session: ORSession
    var athlete: ORAthlete
    
    init(session: ORSession, currentAthlete athlete: ORAthlete) {
        self.session = session
        self.athlete = athlete
    }
    
}
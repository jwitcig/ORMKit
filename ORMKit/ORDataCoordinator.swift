//
//  ORDataCoordinator.swift
//  ORMKit
//
//  Created by Developer on 6/18/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

public class ORDataCoordinator {
    
    var dataManager: ORDataManager?
    
    public init() { }
    
}
//
//  ORLiftTemplate.swift
//  TheOneRepMax
//
//  Created by Application Development on 6/10/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

public class ORLiftTemplate: ORModel {
    
    public enum Fields: String {
        case defaultLift
        case liftDescription
        case liftName
        case solo
        case creator
        case organization
        
        enum LocalOnly: String {
            case NoFields
            
            static var allCases: [LocalOnly] {
                return []
            }
            
            static var allValues: [String] {
                return LocalOnly.allCases.map { $0.rawValue }
            }
        }
    }
    
    override public class var entityName: String { return RecordType.ORLiftTemplate.rawValue }
        
    public var defaultLift: Bool = false
    public var liftDescription: String = ""
    public var liftName: String!
    
    public var creator: ORAthlete!
    
}
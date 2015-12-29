//
//  ORMSession.swift
//  ORMKit
//
//  Created by Application Development on 6/13/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif
import CloudKit
import CoreData

public class ORSession {
    
    public static var currentSession = ORSession()
    
    public var currentViewController: UIViewController!

    public var currentAthlete: ORAthlete? {
        get {
            guard let ID = self.currentAthleteID else { return nil }
            return NSManagedObjectContext.contextForCurrentThread().objectWithID(ID) as? ORAthlete
        }
        set {
            if let athlete = newValue {
                do {
                    try athlete.managedObjectContext?.obtainPermanentIDsForObjects([athlete])
                    self.currentAthleteID = athlete.objectID
                } catch { }
            }
        }
    }
    
    private var currentAthleteID: NSManagedObjectID?
    
    private var _localData: ORLocalData!
    public var localData: ORLocalData! {
        get { return _localData }
        set {
            self._localData = newValue
            self._localData.session = self
        }
    }
        
    private var _soloStats: ORSoloStats!
    public var soloStats: ORSoloStats {
        get { return _soloStats }
        set {
            _soloStats = newValue
            _soloStats.session = self
        }
    }
    
    public static let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(NSBundle.allBundles())
    public static let persistentStoreCooridnator = NSPersistentStoreCoordinator(managedObjectModel: ORSession.managedObjectModel!)

    public var managedObjectContext: NSManagedObjectContext!
    
    public init() { }
        
    public func signInLocally() -> (Bool, ORAthlete?) {
        let context = NSManagedObjectContext.contextForCurrentThread()
        
        guard let username = NSUserDefaults.standardUserDefaults().valueForKey("currentAthleteUsername") as? String else {
            return (false, nil)
        }
                
        let usernamePredicate = NSPredicate(key: ORAthlete.Fields.username.rawValue, comparator: .Equals, value: username)
        let (athletes, _) = self.localData.fetchObjects(model: ORAthlete.self, predicates: [usernamePredicate], context: context)
        
        
        let lastLoggedInAthlete = athletes.first
        
        guard let athlete = lastLoggedInAthlete else {
            return (false, nil)
        }
        
        ORAthlete.setCurrentAthlete(athlete)
        return (true, athlete)
    }
 
    public func initDefaultData() {
        let predicate = NSPredicate(key: ORLiftTemplate.Fields.defaultLift.rawValue, comparator: .Equals, value: true)
        let (templates, _) = localData.fetchObjects(model: ORLiftTemplate.self, predicates: [predicate])
        
        guard templates.count == 0 else {
            print("Default data in place")
            return
        }
        
        let hangCleanTemplate = ORLiftTemplate.template()
        hangCleanTemplate.liftName = "Hang Clean"
        hangCleanTemplate.defaultLift = true
        hangCleanTemplate.liftDescription = "Pull up"
        
        let squatTemplate = ORLiftTemplate.template()
        squatTemplate.liftName = "Squat"
        squatTemplate.defaultLift = true
        squatTemplate.liftDescription = "Squat down"
        
        let benchPressTemplate = ORLiftTemplate.template()
        benchPressTemplate.liftName = "Bench Press"
        benchPressTemplate.defaultLift = true
        benchPressTemplate.liftDescription = "Push up"
        
        let deadLiftTemplate = ORLiftTemplate.template()
        deadLiftTemplate.liftName = "Dead Lift"
        deadLiftTemplate.defaultLift = true
        deadLiftTemplate.liftDescription = "Bend at the knees"
        
        localData.save()
    }
    
}

internal protocol DataConvenience {
    init(session: ORSession, dataManager: ORDataManager)
    var dataManager: ORDataManager { get set }
    
    var session: ORSession { get set }
}
//
//  ORMKitTests.swift
//  ORMKitTests
//
//  Created by Application Development on 6/12/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa
import XCTest
import CloudKit

import ORMKit

class ORMKitTests: XCTestCase {
    
    var soloStats = ORSoloStats()
    var entries = [ORLiftEntry]()
    
    var moc: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("TestSettings", ofType: "plist")

        
        var mom = NSManagedObjectModel.mergedModelFromBundles([bundle])!
        
        println(NSBundle.allBundles())
        let modelURL = NSBundle.mainBundle().URLForResource("TheOneRepMax", withExtension: "momd")!
        mom = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        XCTAssertTrue(psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil) != nil)
        self.moc = NSManagedObjectContext()
        self.moc.persistentStoreCoordinator = psc

        let session = ORSession.currentSession
        let container = CKContainer.defaultContainer()
        let publicDatabase = container.publicCloudDatabase
        
        let dataManager = ORDataManager(localDataContext: self.moc, cloudContainer: container, cloudDatabase: publicDatabase)
        
        ORSession.currentSession.localData = ORLocalData(session: session, dataManager: dataManager)
        ORSession.currentSession.cloudData = ORCloudData(session: session, dataManager: dataManager)
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

        for i in 0..<10 {
            let entry = ORLiftEntry.entry()
            entry.weightLifted = 300
            entry.reps = 3
            entry.date = gregorian.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: -2*i, toDate: NSDate(), options: NSCalendarOptions.allZeros)!

            self.entries.append(entry)
        }
        println(self.entries)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
//        self.soloStats.estimatedMax(targetDate: <#NSDate#>, rawEntries: <#[ORLiftEntry]#>)
        
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

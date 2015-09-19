//
//  ORMKitTests.swift
//  ORMKitTests
//
//  Created by Application Development on 6/12/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

//#if os(iOS)

//import XCTest
//import CloudKit
//
//import ORMKit
//
//class ORMKitTests: XCTestCase {
//    
//    var soloStats = ORSoloStats()
//    var entries = [ORLiftEntry]()
//    
//    
//    let dateFormatter = NSDateFormatter()
//    
//    var moc: NSManagedObjectContext!
//    
//    let testBundle = NSBundle(forClass: ORModel.self)
//
//    override func setUp() {
//        super.setUp()
//        
//        self.dateFormatter.dateFormat = "MM/dd/yy"
//        
//        
//        var mom = NSManagedObjectModel.mergedModelFromBundles([self.testBundle])!
//        
//        let modelURL = self.testBundle.URLForResource("TheOneRepMax", withExtension: "momd")!
//        mom = NSManagedObjectModel(contentsOfURL: modelURL)!
//        
//        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
//        
//        do {
//            try psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
//            
//        } catch _ { }
//        
//        
//        self.moc = NSManagedObjectContext(parentContext: nil)
//        self.moc.persistentStoreCoordinator = psc
//        
//        let session = ORSession.currentSession
//        let container = CKContainer.defaultContainer()
//        let publicDatabase = container.publicCloudDatabase
//        
//        let dataManager = ORDataManager(localDataContext: self.moc, cloudContainer: container, cloudDatabase: publicDatabase)
//        
//        ORSession.currentSession.localData = ORLocalData(session: session, dataManager: dataManager)
//        ORSession.currentSession.cloudData = ORCloudData(session: session, dataManager: dataManager)
//        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//        
//        let liftEntryData = [
//            (300, 3, self.dateFormatter.dateFromString("7/2/15")),
//            (300, 4, self.dateFormatter.dateFromString("7/6/15")),
//            (315, 2, self.dateFormatter.dateFromString("7/12/15")),
//            (320, 2, self.dateFormatter.dateFromString("7/18/15")),
//            (325, 3, self.dateFormatter.dateFromString("7/22/15")),
//            (340, 6, self.dateFormatter.dateFromString("7/30/15")),
//        ]
//        
//        for (i, (weight, reps, date)) in enumerate(liftEntryData) {
//            let entry = ORLiftEntry.entry()
//            entry.weightLifted = weight
//            entry.reps = reps
//            entry.date = date!
//            
//            self.entries.append(entry)
//        }
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//    
//    func testEstimateMax() {
//        
//        
//        var date = self.dateFormatter.dateFromString("7/14/15")!
//        var estimate = self.soloStats.estimatedMax(targetDate: date, rawEntries: self.entries)!
//        XCTAssertEqual(estimate, 338)
//        
//        date = self.dateFormatter.dateFromString("7/27/15")!
//        estimate = self.soloStats.estimatedMax(targetDate: date, rawEntries: self.entries)!
//        XCTAssertEqual(estimate, 388)
//        
//        date = self.dateFormatter.dateFromString("7/6/15")!
//        estimate = self.soloStats.estimatedMax(targetDate: date, rawEntries: self.entries)!
//        XCTAssertEqual(estimate, 340)
//    }
//    
//    func testAverageProgress() {
//        let dateRange = (
//            self.dateFormatter.dateFromString("7/2/15")!,
//            self.dateFormatter.dateFromString("7/29/15")!
//        )
//        let average = self.soloStats.averageProgress(entries: self.entries, dateRange: dateRange, dayInterval: 14)!
//        
//        let date = self.dateFormatter.dateFromString("7/2/15")!
//        let estimate = Float(self.soloStats.estimatedMax(targetDate: date, rawEntries: self.entries)!)
//        
//        let calculatedAnswer = Float(36.8148)
//        let accuracy = average - calculatedAnswer
//        XCTAssertTrue(accuracy < 0.01)
//    }
//    
//    func testDaysBetween() {
//        let date1 = self.dateFormatter.dateFromString("7/14/15")!
//        let date2 = self.dateFormatter.dateFromString("7/15/15")!
//        XCTAssertEqual(NSDate.daysBetween(startDate: date1, endDate: date2), 1)
//    }
//    
//}

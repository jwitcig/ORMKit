//
//  ORSoloStats.swift
//  ORMKit
//
//  Created by Developer on 7/5/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

public class ORSoloStats: ORStats {
        
    public init(athlete: ORAthlete) {
        self.athlete = athlete
        super.init()
    }
    
    var athlete: ORAthlete
    
    private var _allEntries: [ORLiftEntry]!
    public var allEntries: [ORLiftEntry] {
        guard self._allEntries == nil else { return self._allEntries }
        
        let (entries, _) = self.session.localData.fetchLiftEntries(athlete: self.athlete)
    
        self._allEntries = entries
        return self._allEntries
    }
    
    public var defaultTemplate: ORLiftTemplate?
    
    public var currentEntry: ORLiftEntry? {
        return entries().sort { $0.0.date.isBefore(date: $0.1.date) } .first
    }
    
    public var daysSinceLastEntry: Int? {
        return currentEntry?.date.daysBeforeToday()
    }
    
    public func entries(template liftTemplate: ORLiftTemplate? = nil, sort: Sort? = nil) -> [ORLiftEntry] {
        var desiredEntries = self.allEntries
        if let template = liftTemplate ?? defaultTemplate {
            desiredEntries = desiredEntries.filter { $0.liftTemplate == template }
        }
        
        if sort != nil {
            let descriptor = NSSortDescriptor(key: "date", order: sort!)
            desiredEntries = NSArray(array: desiredEntries).sortedArrayUsingDescriptors([descriptor]) as! [ORLiftEntry]
        }
        return desiredEntries
    }
    
    // Gives increase as a percentage of the firstEntry's max
    public func percentageIncrease(firstEntry firstEntry: ORLiftEntry, secondEntry: ORLiftEntry) -> Float {
        return percentageIncrease(firstValue: firstEntry.max.integerValue, secondValue: secondEntry.max.integerValue)
    }
    
    // Gives increase as a percentage of the firstValue
    public func percentageIncrease(firstValue firstValue: Int, secondValue: Int) -> Float {
        let difference = Float(secondValue - firstValue)
        return difference / Float(firstValue) * 100
    }
    
    public func dateRangeOfEntries(liftTemplate liftTemplate: ORLiftTemplate? = nil) -> (NSDate, NSDate)? {
        let sortedEntries = entries(template: liftTemplate, sort: .Chronological)
        if let firstEntryDate = sortedEntries.first?.date,
            let lastEntryDate = sortedEntries.last?.date {
                
                return (firstEntryDate, lastEntryDate)
        }
        return nil
    }
    
    public func averageProgress(dateRange customDateRange: (NSDate, NSDate)? = nil, dayInterval: Int? = nil, liftTemplate: ORLiftTemplate? = nil) -> (Float, (NSDate, NSDate))? {
        guard let template = liftTemplate ?? defaultTemplate else { return nil }
        
        let sortedEntries = entries().sort { $0.0.date.isBefore(date: $0.1.date) }
        guard let dateRange = customDateRange ?? (sortedEntries.first?.date, sortedEntries.last?.date) as? (NSDate, NSDate) else {
            return nil
        }
        
        let initial = self.estimatedMax(targetDate: dateRange.0, liftTemplate: template)
        let final = self.estimatedMax(targetDate: dateRange.1, liftTemplate: template)
        
        
        let dateRangeSpread = NSDate.daysBetween(startDate: dateRange.0, endDate: dateRange.1)
        let interval = dayInterval ?? dateRangeSpread
        
        if let initialMax = initial, finalMax = final {
            let totalProgress = finalMax - initialMax
            let dateRangeSpread = dateRangeSpread
            let dailyProgress = Float(totalProgress) / Float(dateRangeSpread)
            return (dailyProgress * Float(interval), dateRange)
        }
        return nil
    }
    
    public func dayLookback(numberOfDays numberOfDays: Int, liftTemplate: ORLiftTemplate? = nil) -> Float? {
        let today = NSDate()
        let initialDay = today.dateByAddingTimeInterval(Double(-numberOfDays*24*60*60))
        
        return averageProgress(dateRange: (initialDay, today), liftTemplate: liftTemplate)?.0
    }
    
    public func estimatedMax(targetDate targetDate: NSDate, liftTemplate: ORLiftTemplate? = nil) -> Int? {
        guard let template = liftTemplate ?? defaultTemplate else { return nil }
        
        let entries = self.entries(template: template, sort: .Chronological)
        
        if let firstEntry = entries.first {
            if targetDate.isBefore(date: firstEntry.date) && abs(targetDate.daysBetween(endDate: firstEntry.date)) <= 3 {
                return firstEntry.max.integerValue
            }
        }
        if let lastEntry = entries.last {
            if lastEntry.date.isBefore(date: targetDate) && abs(targetDate.daysBetween(endDate: lastEntry.date)) <= 3 {
                return lastEntry.max.integerValue
            }
        }
        
        for (index, entry) in entries.enumerate() {
            let previousEntry = entry
            let nextEntryIndex = index + 1
            
            guard nextEntryIndex < entries.count else { return nil }
            
            let nextEntry = entries[nextEntryIndex]
            
            guard targetDate.isBetween(firstDate: previousEntry.date, secondDate: nextEntry.date, inclusive: true) else {
                continue
            }
            
            guard !targetDate.isSameDay(date: previousEntry.date) else {
                return previousEntry.max.integerValue
            }
            
            guard !targetDate.isSameDay(date: nextEntry.date) else {
                return nextEntry.max.integerValue
            }
            
            let dateRange = NSDate.daysBetween(startDate: previousEntry.date, endDate: nextEntry.date)
            let dateInset = NSDate.daysBetween(startDate: previousEntry.date, endDate: targetDate)
            
            let maxDifference = nextEntry.max.floatValue - previousEntry.max.floatValue
            
            let dateProportion = Float(dateInset) / Float(dateRange)
            
            return Int(
                round(dateProportion * maxDifference + previousEntry.max.floatValue)
            )

        }
        return nil
    }
    
}
//
//  ORSoloStats.swift
//  ORMKit
//
//  Created by Developer on 7/5/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa

public class ORSoloStats: ORStats {
    
    override public init() {
        
    }
    
    public func averageProgress(entries rawEntries: [ORLiftEntry], dayInterval: Int) -> Float? {
        let entries = rawEntries.sorted { $0.0.date.isBefore(date: $0.1.date) }
        
        if let firstEntry = entries.first, lastEntry = entries.last {
            let daysApart = NSDate.daysBetween(startDate: firstEntry.date, endDate: lastEntry.date)
            let totalProgress = lastEntry.max.integerValue - firstEntry.max.integerValue
            let averageDailyProgress = Float(totalProgress) / Float(daysApart)
            return averageDailyProgress * Float(dayInterval)
        }
        return nil
    }
    
    public func estimatedMax(#targetDate: NSDate, rawEntries: [ORLiftEntry]) -> Int? {
        let entries = rawEntries.sorted { $0.0.date.isBefore(date: $0.1.date) }
        
        for (index, entry) in enumerate(entries) {
            let previousEntry = entry
            let nextEntryIndex = index + 1
            
            if nextEntryIndex < count(entries) {
                let nextEntry = entries[nextEntryIndex]
                
                if targetDate.isBetween(firstDate: previousEntry.date, secondDate: nextEntry.date, inclusive: true) {
                    
                    if targetDate.isSameDay(date: previousEntry.date) {
                        return previousEntry.max.integerValue
                    }
                    if targetDate.isSameDay(date: nextEntry.date) {
                        return nextEntry.max.integerValue
                    }
                    
                    let dateRange = NSDate.daysBetween(startDate: previousEntry.date, endDate: nextEntry.date)
                    let dateInset = NSDate.daysBetween(startDate: previousEntry.date, endDate: targetDate)
                    
                    let maxDifference = nextEntry.max.floatValue - previousEntry.max.floatValue
                    
                    let dateProportion = Float(dateInset) / Float(dateRange)
                    
                    return Int(dateProportion * maxDifference + previousEntry.max.floatValue)
                }
            }
        }
        return nil
    }
    
}
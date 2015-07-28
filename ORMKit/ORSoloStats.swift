//
//  ORSoloStats.swift
//  ORMKit
//
//  Created by Developer on 7/5/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Cocoa

public class ORSoloStats: ORStats {
        
    public init(athlete: ORAthlete) {
        self.athlete = athlete
        super.init()
    }
    
    var athlete: ORAthlete
    
    private var _entries: [ORLiftEntry]!
    var entries: [ORLiftEntry] {
        if let objects = self._entries {
            return objects
        }
        let response = self.session.localData.fetchLiftEntries(athlete: self.athlete, organization: self.session.currentOrganization!)
        self._entries = response.objects as! [ORLiftEntry]
        return self._entries
    }
    
    private func entries(template liftTemplate: ORLiftTemplate? = nil, order: Sort? = nil) -> [ORLiftEntry] {
        
        var desiredEntries = self.entries
        if let template = liftTemplate {
            desiredEntries = desiredEntries.filter { $0.liftTemplate == template }
        }
        
        if let sort = order {
            let descriptor = NSSortDescriptor(key: "date", order: .Chronological)
            desiredEntries = NSArray(array: desiredEntries).sortedArrayUsingDescriptors([descriptor]) as! [ORLiftEntry]
        }
        return desiredEntries
    }
    
    public func averageProgress(template template: ORLiftTemplate, dateRange: (NSDate, NSDate), dayInterval: Int) -> Float? {
        let entries = self.entries(template: template, order: .Chronological)
        
        let initial = self.estimatedMax(targetDate: dateRange.0, template: template)
        let final = self.estimatedMax(targetDate: dateRange.1, template: template)
        
        if let initialMax = initial, finalMax = final {
            let totalProgress = finalMax - initialMax
            let dateRangeSpread = NSDate.daysBetween(startDate: dateRange.0, endDate: dateRange.1)
            let dailyProgress = Float(totalProgress) / Float(dateRangeSpread)
            return dailyProgress * Float(dayInterval)
        }
        return nil
    }
    
    public func estimatedMax(targetDate targetDate: NSDate, template: ORLiftTemplate) -> Int? {
        let entries = self.entries(template: template, order: .Chronological)
        
        for (index, entry) in entries.enumerate() {
            let previousEntry = entry
            let nextEntryIndex = index + 1
            
            if nextEntryIndex < entries.count {
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
                    
                    return Int(
                        round(dateProportion * maxDifference + previousEntry.max.floatValue)
                    )
                }
            }
        }
        return nil
    }
    
}
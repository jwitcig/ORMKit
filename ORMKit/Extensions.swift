//
//  Extensions.swift
//  ORMKit
//
//  Created by Developer on 7/10/15.
//  Copyright (c) 2015 JwitApps. All rights reserved.
//

import Foundation


extension String {
    
    var range: Range<String.Index> {
        return Range<String.Index>(start: self.startIndex, end: self.endIndex)
    }
    
    func isBefore(#toString: String) -> Bool {
        return self.compare(toString, options: NSStringCompareOptions.CaseInsensitiveSearch, range: self.range, locale: nil) == .OrderedAscending
    }
    
}

extension NSDate {
    
    func isBefore(#date: NSDate) -> Bool {
        return self.compare(date) == .OrderedAscending
    }
    
    func isSameDay(#date: NSDate) -> Bool {
        return self.compare(date) == .OrderedSame
    }

    public class func daysBetween(#startDate: NSDate, endDate: NSDate) -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dateComponents = calendar.components(.CalendarUnitDay, fromDate: startDate, toDate: endDate, options: NSCalendarOptions.allZeros)
        return dateComponents.day
    }
    
    class func sorted(#dates: [NSDate]) -> [NSDate] {
        return dates.sorted { $0.0.isBefore(date: $0.1) }
    }
    
    func isBetween(#firstDate: NSDate, secondDate: NSDate, inclusive: Bool) -> Bool {
        if self.isSameDay(date: firstDate) || self.isSameDay(date: secondDate) {
            if inclusive { return true }
            else { return false }
        }
        return firstDate.isBefore(date: self) && self.isBefore(date: secondDate)
    }
    
}

extension NSSortDescriptor {
    
    convenience init(key: String, order: Sort) {
        switch order {
        case .Chronological:
            self.init(key: key, ascending: true)
        case .ReverseChronological:
            self.init(key: key, ascending: false)
        }
    }
    
}
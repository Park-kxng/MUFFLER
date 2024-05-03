//
//  Date.swift
//  Money-Planner
//
//  Created by seonwoo on 2024/01/20.
//

import Foundation

extension Date {
    var weekday : Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    var firstDayOfTheMonth : Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    func isInRange(startDate: Date, endDate: Date) -> Bool {
        return self >= startDate && self <= endDate
    }
    
    func toString(format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    
    static var todayAtMidnight: Date {
        let now = Date() // Current date and time
        
        var calendar = Calendar.current // User's current calendar
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")! // Set calendar to use Korea Standard Time
        
        // Extract year, month, and day components from 'now'
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        // Construct a new DateComponents object using the extracted year, month, and day
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        // Also, set hour, minute, and second to 0 to ensure the Date represents the start of the day
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.timeZone = TimeZone(identifier: "Asia/Seoul")! // Ensure the components are interpreted in KST
        
        // Use the calendar to construct a new Date object from these components
        guard let midnightDate = calendar.date(from: dateComponents) else {
            fatalError("Unable to construct the midnight date")
        }
        
        return midnightDate
    }
    
    static func formatDate(_ date: Date, timeZoneIdentifier: String = "UTC", dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        return formatter.string(from: date)
    }
    
}

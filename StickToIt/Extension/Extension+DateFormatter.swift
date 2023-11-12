//
//  Extension+DateFormatter.swift
//  StickToIt
//
//  Created by 서동운 on 10/4/23.
//

import Foundation

extension DateFormatter {
    
    private static let shared = DateFormatter()
    
    enum Format: String {
        case calendarHeader = "MMM yyyy"
        case time = "HH:mm"
    }
    
    static func formatToString(format: Format, from date: Date) -> String {
        shared.locale = .current
        shared.dateFormat = format.rawValue
        
        return shared.string(from: date)
    }
    
    static func formatToDate(format: Format, from string: String) -> Date? {
        shared.locale = .current
        shared.dateFormat = format.rawValue
        
        return shared.date(from: string)
    }
    
    static func getFullDateString(from date: Date) -> String {
        shared.locale = .current
        shared.dateFormat = "yyyy.MM.dd E"
        return shared.string(from: date)
    }
    
    static func getTimeString(from date: Date) -> String {
        shared.locale = .current
        shared.timeStyle = .medium
        shared.dateStyle = .none
        return shared.string(from: date)
    }
    
    static func convertDate(from date: Date, contains components: Set<Calendar.Component> = [.year, .month, .day, .weekday]) -> Date? {
        shared.locale = .current
        shared.dateStyle = .full
        shared.timeStyle = .long
        
        let dateComponents = Calendar.current.dateComponents(components, from: date)
        
        return Calendar.current.date(from: dateComponents)
    }
    
    static func convertToDateQuery(_ date: Date?, components: Set<Calendar.Component> = [.year, .month, .day]) -> DateQuery? {
        guard let _date = date else { return nil }
        
        let _dateComponents = Calendar.current.dateComponents(components, from: _date)
        
        guard let _day = DateFormatter.convertDate(from: _date, contains: components) else { return nil }
    
        return DateQuery(
            date: _day,
            dateComponents: _dateComponents
        )
    }
}

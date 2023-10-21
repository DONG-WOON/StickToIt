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
    }
    
    static func formatToString(format: Format, from date: Date) -> String {
        shared.dateFormat = format.rawValue
        
        return shared.string(from: date)
    }
    
    static func formatToDate(format: Format, from string: String) -> Date? {
        shared.dateFormat = format.rawValue
        
        return shared.date(from: string)
    }
    
    static func getFullDateString(from date: Date) -> String {
        shared.dateFormat = "yyyy.MM.dd E"
        return shared.string(from: date)
    }
    
    static func getTimeString(from date: Date) -> String {
        shared.timeStyle = .medium
        shared.dateStyle = .none
        return shared.string(from: date)
    }
    
    static func convertDate(from date: Date) -> Date? {
        shared.dateStyle = .full
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: date)
        
        return Calendar.current.date(from: dateComponents)
    }
}

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
        case clendarHeader = "MMM yyyy"
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
}

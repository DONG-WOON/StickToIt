//
//  Extension+DateFormatter.swift
//  StickToIt
//
//  Created by 서동운 on 10/4/23.
//

import Foundation

extension DateFormatter {
    static let monthYearFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
    
    static let dayPlanFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
}

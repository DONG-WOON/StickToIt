//
//  Plan.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation


struct Plan: Identifiable {
    let id: UUID
    let name: String
    let targetNumberOfDays: Int
    let startDate: Date
    let endDate: Date
    var dayPlans: [DayPlan]
    
    var totalWeek: Int {
        return Calendar.current.dateComponents([.weekOfYear], from: startDate, to: endDate).weekOfYear! + 1
    }
    
    var currentWeek: Int {
        let weekOfYear = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: Date.now).weekOfYear!
        return weekOfYear + 1
    }
    
//    var completed
    
    init(
        id: UUID,
        name: String,
        targetNumberOfDays: Int,
        startDate: Date,
        endDate: Date,
        dayPlans: [DayPlan]
    ) {
        self.id = id
        self.name = name
        self.targetNumberOfDays = targetNumberOfDays
        self.startDate = startDate
        self.endDate = endDate
        self.dayPlans = dayPlans
    }
    
}

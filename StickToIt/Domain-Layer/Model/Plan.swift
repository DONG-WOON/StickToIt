//
//  Plan.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation


struct Plan {
    private(set) var _id: UUID
    let name: String
    let targetNumberOfDays: Int
    let startDate: Date
    let endDate: Date
    let executionDaysOfWeek: Set<Week>
    var dayPlans: [DayPlan]
    
    var totalWeek: Int {
        return targetNumberOfDays / 7 == 0 ? 1 : targetNumberOfDays / 7
    }
    
    var currentWeek: Int {
        let weekOfYear = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: Date.now).weekOfYear
        guard let weekOfYear else { return 1 }
        return weekOfYear < 1 ? 1 : weekOfYear
    }
    
//    var completed
    
    init(
        _id: UUID,
        name: String,
        targetNumberOfDays: Int,
        startDate: Date,
        endDate: Date,
        executionDaysOfWeek: Set<Week>,
        dayPlans: [DayPlan]
    ) {
        self._id = _id
        self.name = name
        self.targetNumberOfDays = targetNumberOfDays
        self.startDate = startDate
        self.endDate = endDate
        self.executionDaysOfWeek = executionDaysOfWeek
        self.dayPlans = dayPlans
    }
    
}

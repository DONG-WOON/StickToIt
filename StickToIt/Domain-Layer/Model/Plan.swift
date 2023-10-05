//
//  Plan.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation


struct Plan {
    private(set) var _id: UUID
    var name: String
    var targetPeriod: Int
    var startDate: Date
    var executionDaysOfWeek: Set<Week>
    //    let endDate: String // startDate 기점으로 시간결졍?
    var weeklyPlans: [WeeklyPlan]
    
    init(
        _id: UUID,
        name: String,
        targetPeriod: Int,
        startDate: Date,
        executionDaysOfWeek: Set<Week>,
        weeklyPlans: [WeeklyPlan]
    ) {
        self._id = _id
        self.name = name
        self.targetPeriod = targetPeriod
        self.startDate = startDate
        self.executionDaysOfWeek = executionDaysOfWeek
        self.weeklyPlans = weeklyPlans
    }
}

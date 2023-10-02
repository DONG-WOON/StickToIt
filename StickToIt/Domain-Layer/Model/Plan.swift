//
//  Plan.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation


final class Plan {
    private(set) var _id: UUID
    var title: String
    var targetWeek: Int
    var startDate: Date
    //    let endDate: String // startDate 기점으로 시간결졍?
    var weeklyPlans: [WeeklyPlan]
    
    convenience init(
        title: String,
        targetWeek: Int,
        startDate: Date
    ) {
        self.init(
            _id: UUID(),
            title: title,
            targetWeek: targetWeek,
            startDate: startDate,
            weeklyPlans: []
        )
    }
    
    init(
        _id: UUID,
        title: String,
        targetWeek: Int,
        startDate: Date,
        weeklyPlans: [WeeklyPlan]
    ) {
        self._id = _id
        self.title = title
        self.targetWeek = targetWeek
        self.startDate = startDate
        self.weeklyPlans = weeklyPlans
    }
}


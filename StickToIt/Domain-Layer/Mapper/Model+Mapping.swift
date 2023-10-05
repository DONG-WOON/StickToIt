//
//  Model+Mapping.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation
import RealmSwift

extension User {
    func toEntity() -> UserEntity {
        return .init(name: name)
    }
}

extension Plan {
    func toEntity() -> PlanEntity {
        
        let _executionDaysOfWeek = MutableSet<Week>()
        _executionDaysOfWeek.insert(objectsIn: executionDaysOfWeek)
        
        let _weeklyPlans = List<WeeklyPlanEntity>()
        _weeklyPlans.append(objectsIn: weeklyPlans.map { $0.toEntity() })
        
        return .init(
            name: name,
            targetPeriod: targetPeriod,
            startDate: startDate,
            executionDaysOfWeek: _executionDaysOfWeek,
            weeklyPlans: _weeklyPlans
        )
    }
}

extension WeeklyPlan {
    func toEntity() -> WeeklyPlanEntity {
        
        let _dayPlans = List<DayPlanEntity>()
        _dayPlans.append(objectsIn: dayPlans.map { $0.toEntity() })
        
        return .init(
            week: week,
            dayPlans: _dayPlans
        )
    }
}

extension DayPlan {
    func toEntity() -> DayPlanEntity {
        return .init(
            date: date,
            imageURL: imageURL,
            content: content
        )
    }
}

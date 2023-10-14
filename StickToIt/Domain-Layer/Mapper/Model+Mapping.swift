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
        
        let _executionDaysOfWeekday = MutableSet<Week>()
        _executionDaysOfWeekday.insert(objectsIn: executionDaysOfWeekday)
        
        let _dayPlans = List<DayPlanEntity>()
        _dayPlans.append(objectsIn: dayPlans.map { $0.toEntity() })
        
        return .init(
            name: name,
            targetNumberOfDays: targetNumberOfDays,
            startDate: startDate,
            endDate: endDate,
            executionDaysOfWeekday: _executionDaysOfWeekday,
            dayPlans: _dayPlans
        )
    }
}
//
//extension WeeklyPlan {
//    func toEntity() -> WeeklyPlanEntity {
//
//        let _dayPlans = List<DayPlanEntity>()
//        _dayPlans.append(objectsIn: dayPlans.map { $0.toEntity() })
//
//        return .init(
//            week: week,
//            dayPlans: _dayPlans
//        )
//    }
//}

extension DayPlan {
    func toEntity() -> DayPlanEntity {
        return .init(
            date: date,
            isRequired: isRequired,
            isComplete: isComplete,
            week: week,
            content: content,
            imageURL: imageURL
        )
    }
}

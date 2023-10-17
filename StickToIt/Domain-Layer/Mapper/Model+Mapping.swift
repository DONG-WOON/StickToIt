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
        
        let _planQueries = List<PlanQueryEntity>()
        _planQueries.append(objectsIn: planQueries.map { $0.toEntity() })
        
        return .init(
            _id: _id,
            name: name,
            planQueries: _planQueries
        )
    }
}

extension PlanQuery {
    func toEntity() -> PlanQueryEntity {
        return .init(
            _id: planID,
            planName: planName
        )
    }
}

extension Plan {
    func toEntity() -> PlanEntity {
        
        let _executionDaysOfWeekday = MutableSet<Week>()
        _executionDaysOfWeekday.insert(objectsIn: executionDaysOfWeekday)
        
        let _dayPlans = List<DayPlanEntity>()
        _dayPlans.append(objectsIn: dayPlans.map { $0.toEntity() })
        
        return .init(
            _id: _id,
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
            imageURL: imageURL,
            imageContentIsFill: imageContentIsFill
        )
    }
}

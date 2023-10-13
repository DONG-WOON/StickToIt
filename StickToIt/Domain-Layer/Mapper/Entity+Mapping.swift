//
//  Entity+Mapping.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation
import RealmSwift

extension UserEntity {
    func toDomain() -> User {
        return .init(
            _id: _id,
            name: name,
            plans: plans.map { $0.toDomain() }
        )
    }
}

extension PlanEntity {
    func toDomain() -> Plan {

        return .init(
            _id: _id,
            name: name,
            targetNumberOfDays: targetNumberOfDays,
            startDate: startDate,
            endDate: endDate,
            executionDaysOfWeekday: Set(executionDaysOfWeekday),
            dayPlans: dayPlans.map { $0.toDomain() }
        )
    }
}

extension DayPlanEntity {
    func toDomain() -> DayPlan {
        return .init(
            _id: _id,
            isRequired: isRequired,
            isComplete: isComplete,
            date: date,
            week: week,
            content: content
        )
    }
}

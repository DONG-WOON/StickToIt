//
//  Entity+Mapping.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation

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
            title: title,
            targetWeek: targetWeek,
            startDate: startDate,
            weeklyPlans: weeklyPlans.map { $0.toDomain() }
        )
    }
}

extension WeeklyPlanEntity {
    func toDomain() -> WeeklyPlan {
        return .init(
            week: week,
            dayPlans: dayPlans.map { $0.toDomain() }
        )
    }
}

extension DayPlanEntity {
    func toDomain() -> DayPlan {
        return .init(
            _id: _id,
            date: date,
            imageURL: imageURL,
            content: content
        )
    }
}

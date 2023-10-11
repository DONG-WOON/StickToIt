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
            executionDaysOfWeek: Set(executionDaysOfWeek),
            dayPlans: dayPlans.map { $0.toDomain() }
        )
    }
}

extension DayPlanEntity {
    func toDomain() -> DayPlan {
        return .init(
            _id: _id,
            date: date,
            week: week,
            imageData: imageData,
            content: content
        )
    }
}

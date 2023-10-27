//
//  Entity+Mapping.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation
import RealmSwift

protocol Entity<Model> {
    associatedtype Model
    func toDomain() -> Model
}

extension UserEntity: Entity {
    func toDomain() -> User {
        return .init(
            id: _id,
            name: name,
            planQueries: planQueries.map { $0.toDomain() }
        )
    }
}

extension PlanQueryEntity: Entity {
    func toDomain() -> PlanQuery {
        .init(
            id: _id,
            planName: planName
        )
    }
}

extension PlanEntity: Entity {
    func toDomain() -> Plan {

        return .init(
            id: _id,
            name: name,
            targetNumberOfDays: targetNumberOfDays,
            startDate: startDate,
            endDate: endDate,
            dayPlans: dayPlans.map { $0.toDomain() }
        )
    }
}

extension DayPlanEntity: Entity {
    func toDomain() -> DayPlan {
        return .init(
            id: _id,
            isRequired: isRequired,
            isComplete: isComplete,
            date: date,
            week: week,
            content: content,
            imageURL: imageURL
        )
    }
}

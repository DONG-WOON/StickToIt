//
//  Model+Mapping.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation
import RealmSwift

protocol Model<Entity> {
    associatedtype Entity: Object
    func toEntity() -> Entity
}

extension User: Model {
    func toEntity() -> UserEntity {
        
        let _planQueries = List<PlanQueryEntity>()
        _planQueries.append(objectsIn: planQueries.map { $0.toEntity() })
        
        return .init(
            _id: id,
            name: name,
            planQueries: _planQueries
        )
    }
}

extension PlanQuery: Model {
    func toEntity() -> PlanQueryEntity {
        return .init(
            _id: id,
            planName: planName
        )
    }
}

extension Plan: Model {
    func toEntity() -> PlanEntity {
    
        let _dayPlans = List<DayPlanEntity>()
        _dayPlans.append(objectsIn: dayPlans.map { $0.toEntity() })
        
        return .init(
            _id: id,
            name: name,
            targetNumberOfDays: targetNumberOfDays,
            startDate: startDate,
            endDate: endDate,
            dayPlans: _dayPlans
        )
    }
}

extension DayPlan: Model {
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

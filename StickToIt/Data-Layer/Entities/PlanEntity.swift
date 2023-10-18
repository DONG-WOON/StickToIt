//
//  PlanEntity.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation
import RealmSwift

final class PlanEntity: Object {
    @Persisted(primaryKey: true) var _id: UUID
    @Persisted var name: String
    @Persisted var targetNumberOfDays: Int
    @Persisted var startDate: Date
    @Persisted var endDate: Date
    @Persisted var executionDaysOfWeekday: MutableSet<Week>
    @Persisted var dayPlans: List<DayPlanEntity>
    
    #warning("id 초기화 하진않아도 생기는지 확인")
    
    convenience init(
        _id: UUID,
        name: String,
        targetNumberOfDays: Int,
        startDate: Date,
        endDate: Date,
        executionDaysOfWeekday: MutableSet<Week>,
        dayPlans: List<DayPlanEntity>
        ) {
            self.init()
            
            self._id = _id
            self.name = name
            self.targetNumberOfDays = targetNumberOfDays
            self.startDate = startDate
            self.endDate = endDate
            self.executionDaysOfWeekday = executionDaysOfWeekday
            self.dayPlans = dayPlans
        }
}

enum Week: Int, CaseIterable, PersistableEnum {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var description: String {
        switch self {
        case .monday:
            return "monday"
        case .tuesday:
            return "tuesday"
        case .wednesday:
            return "wednesday"
        case .thursday:
            return "thursday"
        case .friday:
            return "friday"
        case .saturday:
            return "saturday"
        case .sunday:
            return "sunday"
        }
    }
    
    var kor: String {
        switch self {
        case .monday:
            return "월"
        case .tuesday:
            return "화"
        case .wednesday:
            return "수"
        case .thursday:
            return "목"
        case .friday:
            return "금"
        case .saturday:
            return "토"
        case .sunday:
            return "일"
        }
    }
}



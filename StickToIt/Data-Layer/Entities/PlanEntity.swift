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
    
    @Persisted var executionDaysOfWeek: MutableSet<Week>
    @Persisted var dayPlans: List<DayPlanEntity>
    
    @Persisted(originProperty: "plans") var user: LinkingObjects<UserEntity>
    
    #warning("id 초기화 하진않아도 생기는지 확인")
    
    convenience init(
        name: String,
        targetNumberOfDays: Int,
        startDate: Date,
        endDate: Date,
        executionDaysOfWeek: MutableSet<Week>,
        dayPlans: List<DayPlanEntity>
        ) {
            self.init()
            
            self.name = name
            self.targetNumberOfDays = targetNumberOfDays
            self.startDate = startDate
            self.endDate = endDate
            self.executionDaysOfWeek = executionDaysOfWeek
            self.dayPlans = dayPlans
        }
}

#warning("DateFormatter와 함꼐 사용해보기")
enum Week: Int, CaseIterable, PersistableEnum {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
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



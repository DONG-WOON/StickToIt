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
    @Persisted var title: String
    @Persisted var targetWeek: Int
    @Persisted var startDate: Date
    @Persisted var weeklyPlans: List<WeeklyPlanEntity>
    
    @Persisted(originProperty: "plans") var user: LinkingObjects<UserEntity>
    
    #warning("id 초기화 하진않아도 생기는지 확인")
    convenience init(
        title: String,
        targetWeek: Int,
        startDate: Date
        ) {
            self.init()
            
            self.title = title
            self.targetWeek = targetWeek
            self.startDate = startDate
        }
}


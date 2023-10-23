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
    @Persisted var dayPlans: List<DayPlanEntity>
    
    
    convenience init(
        _id: UUID,
        name: String,
        targetNumberOfDays: Int,
        startDate: Date,
        endDate: Date,
        dayPlans: List<DayPlanEntity>
        ) {
            self.init()
            
            self._id = _id
            self.name = name
            self.targetNumberOfDays = targetNumberOfDays
            self.startDate = startDate
            self.endDate = endDate
            self.dayPlans = dayPlans
        }
}



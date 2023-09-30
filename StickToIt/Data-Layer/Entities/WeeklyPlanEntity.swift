//
//  WeeklyPlanEntity.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation
import RealmSwift

final class WeeklyPlanEntity: Object {
    @Persisted var dayPlans: List<DayPlanEntity>
    
    @Persisted(originProperty: "weeklyPlans") var plan: LinkingObjects<PlanEntity>
    
    convenience init(
        dayPlans: List<DayPlanEntity>
    ) {
        self.init()
        
        self.dayPlans = dayPlans
    }
}

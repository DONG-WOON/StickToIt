//
//  WeeklyPlan.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import Foundation

struct WeeklyPlan {
   var dayPlans: [DayPlan]
    
    init(dayPlans: [DayPlan]) {
        self.dayPlans = dayPlans
    }
}

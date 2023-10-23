//
//  PlanQuery.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import Foundation

struct PlanQuery: Codable, Equatable {
    let planID: UUID
    let planName: String
    
    init(
        planID: UUID,
        planName: String
    ) {
        self.planID = planID
        self.planName = planName
    }
}

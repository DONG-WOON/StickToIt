//
//  PlanQuery.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import Foundation

struct PlanQuery: Codable, Equatable, Identifiable {
    let id: UUID
    let planName: String
    
    init(
        id: UUID,
        planName: String
    ) {
        self.id = id
        self.planName = planName
    }
}

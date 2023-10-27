//
//  User.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation

struct User: Equatable, Identifiable {
    var id: UUID
    var name: String
    var planQueries: [PlanQuery]
    
    init(
        id: UUID,
        name: String,
        planQueries: [PlanQuery]
    ) {
        self.id = id
        self.name = name
        self.planQueries = planQueries
    }
}

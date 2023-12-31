//
//  User.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation

struct User: Equatable, Identifiable {
    var id: UUID
    var nickname: String
    var planQueries: [PlanQuery]
    
    init(
        id: UUID,
        nickname: String,
        planQueries: [PlanQuery]
    ) {
        self.id = id
        self.nickname = nickname
        self.planQueries = planQueries
    }
}

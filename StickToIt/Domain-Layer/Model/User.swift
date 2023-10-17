//
//  User.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation

struct User: Equatable {
    var _id: UUID
    var name: String
    var planQueries: [PlanQuery]
    
    init(
        _id: UUID,
         name: String,
        planQueries: [PlanQuery]
    ) {
        self._id = _id
        self.name = name
        self.planQueries = planQueries
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs._id == rhs._id && lhs.name == rhs.name
    }
}

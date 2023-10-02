//
//  User.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation

final class User: Equatable {
    var _id: UUID
    var name: String
    
    var plans: [Plan]
    
    init(
        _id: UUID,
         name: String,
         plans: [Plan]
    ) {
        self._id = _id
        self.name = name
        self.plans = plans
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs._id == rhs._id && lhs.name == rhs.name
    }
}

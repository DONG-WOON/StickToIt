//
//  UserEntity.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation
import RealmSwift

final class UserEntity: Object {
    @Persisted(primaryKey: true) var _id: UUID
    @Persisted var nickname: String
    @Persisted var planQueries: List<PlanQueryEntity>
    
    convenience init(
        _id: UUID,
        nickname: String,
        planQueries: List<PlanQueryEntity>
    ) {
        self.init()
        
        self._id = _id
        self.nickname = nickname
        self.planQueries = planQueries
    }
}

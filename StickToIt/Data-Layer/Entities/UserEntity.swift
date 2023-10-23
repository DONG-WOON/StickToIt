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
    @Persisted var name: String
    @Persisted var planQueries: List<PlanQueryEntity>
    
    convenience init(
        _id: UUID,
        name: String,
        planQueries: List<PlanQueryEntity>
    ) {
        self.init()
        
        self._id = _id
        self.name = name
        self.planQueries = planQueries
    }
}

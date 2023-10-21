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
    @Persisted var lastCertifyingDay: Date?
    
    convenience init(
        _id: UUID,
        name: String,
        planQueries: List<PlanQueryEntity>,
        lastCertifyingDay: Date?
        
    ) {
        self.init()
        self._id = _id
        self.name = name
        self.planQueries = planQueries
        self.lastCertifyingDay = lastCertifyingDay
    }
}

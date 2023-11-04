//
//  PlanQueryEntity.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation
import RealmSwift

final class PlanQueryEntity: Object {
    @Persisted(primaryKey: true) var _id: UUID
    @Persisted var planName: String
    
    convenience init(
        _id: UUID,
        planName: String
    ) {
        self.init()
        
        self._id = _id
        self.planName = planName
    }
}

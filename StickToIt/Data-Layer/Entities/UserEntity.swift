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
    @Persisted var plans: List<PlanEntity>
    
    convenience init(
        name: String
    ) {
        self.init()

        self.name = name
    }
}

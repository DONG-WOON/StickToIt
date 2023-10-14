//
//  DayPlanEntity.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation
import RealmSwift

final class DayPlanEntity: Object {
    @Persisted(primaryKey: true) var _id: UUID
    @Persisted var isRequired: Bool
    @Persisted var isComplete: Bool
    @Persisted var date: Date?
    @Persisted var week: Int
    @Persisted var content: String?
    @Persisted var imageURL: String?
    
    @Persisted(originProperty: "dayPlans") var plan: LinkingObjects<PlanEntity>
    
    #warning("image Data or image file 결정")
    
    convenience init(
        date: Date?,
        isRequired: Bool,
        isComplete: Bool,
        week: Int,
        content: String?,
        imageURL: String?
    ) {
        self.init()
        
        self.date = date
        self.isRequired = isRequired
        self.isComplete = isComplete
        self.week = week
        self.content = content
        self.imageURL = imageURL
    }
}

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
    @Persisted var date: Date?
    @Persisted var week: Int
    @Persisted var imageData: Data?
    @Persisted var content: String?
    
    @Persisted(originProperty: "dayPlans") var plan: LinkingObjects<PlanEntity>
    #warning("image Data or image file 결정")
    
    convenience init(
        date: Date?,
        week: Int,
        imageData: Data?,
        content: String?
    ) {
        self.init()
        
        self.date = date
        self.week = week
        self.imageData = imageData
        self.content = content
    }
}

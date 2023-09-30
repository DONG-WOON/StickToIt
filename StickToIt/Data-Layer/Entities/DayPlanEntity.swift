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
    @Persisted var date: Date
    @Persisted var imageURL: String
    @Persisted var content: String
    
    #warning("image Data or image file 결정")
    
    convenience init(
        date: Date,
        imageURL: String,
        content: String
    ) {
        self.init()
        
        self.date = date
        self.imageURL = imageURL
        self.content = content
    }
}

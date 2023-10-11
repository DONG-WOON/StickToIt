//
//  DayPlan.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation

struct DayPlan: Hashable {
    var _id: UUID
    var date: Date?
    var week: Int
    var imageData: Data?
    var content: String?
    
    #warning("image Data or image file 결정")
    
    init(
        _id: UUID,
         date: Date?,
        week: Int,
        imageData: Data?,
        content: String?
    ) {
        self._id = _id
        self.date = date
        self.week = week
        self.imageData = imageData
        self.content = content
    }
}

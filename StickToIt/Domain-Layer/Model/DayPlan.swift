//
//  DayPlan.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation

struct DayPlan: Hashable {
    var _id: UUID
    let isRequired: Bool
    var isComplete: Bool
    var date: Date
    var week: Int
    var content: String?
    var imageURL: String?

    
    init(
        _id: UUID,
        isRequired: Bool,
        isComplete: Bool,
        date: Date,
        week: Int,
        content: String?,
        imageURL: String?
    ) {
        self._id = _id
        self.isRequired = isRequired
        self.isComplete = isComplete
        self.date = date
        self.week = week
        self.content = content
        self.imageURL = imageURL
    }
}

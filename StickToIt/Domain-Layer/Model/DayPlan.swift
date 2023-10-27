//
//  DayPlan.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation

struct DayPlan: Hashable, Identifiable {
    var id: UUID
    let isRequired: Bool
    var isComplete: Bool
    var date: Date
    var week: Int
    var content: String?
    var imageURL: String?

    
    init(
        id: UUID,
        isRequired: Bool,
        isComplete: Bool,
        date: Date,
        week: Int,
        content: String?,
        imageURL: String?
    ) {
        self.id = id
        self.isRequired = isRequired
        self.isComplete = isComplete
        self.date = date
        self.week = week
        self.content = content
        self.imageURL = imageURL
    }
}

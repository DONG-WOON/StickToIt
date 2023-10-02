//
//  DayPlan.swift
//  StickToIt
//
//  Created by 서동운 on 9/29/23.
//

import Foundation

final class DayPlan {
    var _id: UUID
    var date: Date
    var imageURL: String
    var content: String
    
    #warning("image Data or image file 결정")
    
    init(
        _id: UUID,
         date: Date,
         imageURL: String,
        content: String
    ) {
        self._id = _id
        self.date = date
        self.imageURL = imageURL
        self.content = content
    }
}

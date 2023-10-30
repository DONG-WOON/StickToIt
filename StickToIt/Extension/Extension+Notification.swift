//
//  Extension+Notification.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import Foundation

extension Notification.Name {
    static let updateImageToUpload = Notification.Name("updateImageToUpload")
    static let reloadAll = Notification.Name("reloadAll")
    static let reloadPlan = Notification.Name("reloadPlan")
    static let planCreated = Notification.Name("planCreated")
    static let updateNickname = Notification.Name("updateNickname")
}

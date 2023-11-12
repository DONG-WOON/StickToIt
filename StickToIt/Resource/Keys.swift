//
//  Keys.swift
//  StickToIt
//
//  Created by 서동운 on 10/27/23.
//

import Foundation

enum UserDefaultsKey {
    static let currentPlan = "currentPlan"
    static let userID = "userID"
    static let isCertifyingError = "isCertifyingError"
    static let isSaveImageError = "isSaveImageError"
    static let localNotificationIsAllowed = "localNotificationIsAllowed"
    static let localNotificationDate = "localNotificationDate"
}

enum NotificationKey {
    static let imageToUpload = "imageToUpload"
    static let nickname = "nickname"
}

//
//  Const.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import Foundation

enum Const {
    enum Image: String {
        case houseFill = "house.fill"
        case listBullet = "list.bullet"
        case calendar = "calendar"
        case chevronDown = "chevron.down"
        case chevronRight = "chevron.right"
        case chevronLeft = "chevron.left"
        case ellipsis = "ellipsis"
        case plus = "plus"
        case gear = "gearshape.fill"
        case xmark = "xmark"
        case uncheckedCircle = "checkmark.circle"
        case checkedCircle = "checkmark.circle.fill"
        case camera = "camera.shutter.button.fill"
        case pencil = "pencil"
        
        static let scaleAspectFill = "scaleAspectFill"
        static let scaleAspectFit = "scaleAspectFit"
    }
    
    enum NotificationKey {
        static let imageToUpload = "imageToUpload"
    }
    
    enum Key: String {
        case favoritePlans = "favoritePlans"
        case userID = "userID"
    }
    
    enum Size {
        case MB(Int)
        
        var value: Int {
            switch self {
            case .MB(let number) :
                return Int(1024*1024*number)
            }
        }
    }
}

enum AssetColor {
    static let Accent1 = "Accent1"
    static let Accent2 = "Accent2"
    static let Accent3 = "Accent3"
    static let Accent4 = "Accent4"
    static let Black = "Black"
}

enum FontSize {
    static let title: CGFloat = 30
    static let body: CGFloat = 17
    static let description:CGFloat = 15
}

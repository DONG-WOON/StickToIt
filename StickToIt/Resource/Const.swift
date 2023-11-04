//
//  Const.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import Foundation

enum Const {
    enum SymbolImage: String {
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
        case aspectratio = "aspectratio"
        case textformat = "textformat"
        case textSize = "textformat.size"
        case trash = "trash"
        case timer = "timer"
        case text = "t.circle"
        case xmarkCircleFill = "xmark.circle.fill"
    }
    
    enum AssetImage: String {
        case placeholder = "Placeholder"
    }

    enum AssetColor: String {
        case accent1 = "Accent1"
        case accent2 = "Accent2"
        case accent3 = "Accent3"
        case accent4 = "Accent4"
        case black = "Black"
    }

    enum FontSize {
        
        /// 27
        static let title: CGFloat = 27
        
        /// 21
        static let subTitle: CGFloat = 21
        
        /// 18
        static let body: CGFloat = 17
        
        /// 14
        static let description:CGFloat = 14
    }

    
    enum Size {
        case kb(Int)
        
        var value: Int {
            switch self {
            case .kb(let number) :
                return Int(1024*number)
            }
        }
    }
}

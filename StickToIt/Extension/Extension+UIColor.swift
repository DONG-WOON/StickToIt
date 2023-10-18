//
//  Extension+UIColor.swift
//  StickToIt
//
//  Created by 서동운 on 10/18/23.
//

import UIKit

extension UIColor {
    static func assetColor(_ name: AssetColor) -> UIColor {
        return UIColor(named: name.rawValue) ?? .clear
    }
}

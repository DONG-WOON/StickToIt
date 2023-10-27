//
//  Extension+UIImage.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import UIKit

extension UIImage {
    convenience init?(resource: Const.SymbolImage) {
        self.init(systemName: resource.rawValue)
    }
    
    convenience init?(asset: Const.AssetImage) {
        self.init(named: asset.rawValue)
    }
}

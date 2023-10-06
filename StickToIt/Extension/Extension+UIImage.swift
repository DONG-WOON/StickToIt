//
//  Extension+UIImage.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import UIKit

extension UIImage {
    convenience init?(resource: Const.Image) {
        self.init(systemName: resource.rawValue)
    }
}

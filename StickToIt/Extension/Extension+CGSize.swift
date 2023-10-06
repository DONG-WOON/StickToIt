//
//  Extension+CGSize.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import UIKit


extension CGSize {
    
    @MainActor
    static var thumbnail: CGSize {
        let scale = UIScreen.main.scale
        let width = UIScreen.main.bounds.width
        return CGSize(width: (width / 3) * scale, height: 100 * scale)
    }
}

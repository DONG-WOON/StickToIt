//
//  BaseViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import UIKit

protocol BaseViewConfigurable: AnyObject {
    
    func configureViews()
    func setConstraints()
}

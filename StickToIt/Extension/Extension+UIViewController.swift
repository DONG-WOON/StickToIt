//
//  Extension+UIViewController.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import UIKit

extension UIViewController {
    func embedNavigationController() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self)
        return navigationController
    }
    
    func goToSetting() {
        guard let settingURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingURL) else { return }
        UIApplication.shared.open(settingURL, options: [:])
    }
}

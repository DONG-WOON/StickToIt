//
//  Extension+UIViewController.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import UIKit

// MARK: Functions
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
    
    func showAlert(title: String, message: String, okAction: (() ->  Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: StringKey.yes.localized(), style: .default) { _ in
            okAction?()
        }
        let cancelAction = UIAlertAction(title: StringKey.no.localized(), style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}

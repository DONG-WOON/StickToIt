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
    
    func showAlert(title: String, message: String, okAction: @escaping () ->  Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "예", style: .default) { _ in
            okAction()
        }
        let cancelAction = UIAlertAction(title: "아니오", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}

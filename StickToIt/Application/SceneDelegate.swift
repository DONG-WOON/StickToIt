//
//  SceneDelegate.swift
//  StickToIt
//
//  Created by 서동운 on 9/20/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let userIsExist = checkUserIsExist()
        
        if userIsExist {
            window?.rootViewController = TabBarController()
        } else {
            window?.rootViewController = UserSettingViewController(
                viewModel: DIContainer.makeUserSettingViewModel()
            ).embedNavigationController()
        }
        
        window?.makeKeyAndVisible()
        
        if let window {
            UIView.transition(
                with: window,
                duration: 0.6,
                options: .transitionCrossDissolve,
                animations: nil
            )
        }
    }
    
    func checkUserIsExist() -> Bool {
        if let userIDString = UserDefaults.standard.string(forKey: UserDefaultsKey.userID),
            let _ = UUID(uuidString: userIDString) {
                return true
        } else {
            return false
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
 
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {
    
    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
 
    }
}


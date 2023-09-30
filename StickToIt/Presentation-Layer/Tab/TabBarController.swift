//
//  TabBarController.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import UIKit
import SnapKit

final class TabBarController: UITabBarController {

    // MARK: Properties
    
    let homeVC = HomeViewController()
        .configureTabBarItem(title: "Home", image: UIImage(systemName: Const.Image.houseFill))
        .embedNavigationController()
    
    
    // MARK: View Life Cycle

    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .systemBackground
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = .label
        tabBarAppearance.isTranslucent = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [homeVC]
    }
}

extension UIViewController {
    func configureTabBarItem(title: String, image: UIImage?) -> UIViewController {
        self.tabBarItem.title = title
        self.tabBarItem.image = image
        return self
    }
}


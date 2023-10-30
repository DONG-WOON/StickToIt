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
    
    let homeVC = HomeViewController(
        viewModel: DIContainer.makeHomeViewModel()
    ).configureTabBarItem(title: "홈", image: UIImage(resource: .houseFill))
        .embedNavigationController()
    
    let calendarVC = CalendarViewController(
        viewModel: DIContainer.makeCalendarViewModel())
        .configureTabBarItem(title: "캘린더", image: UIImage(resource: .calendar))
        .embedNavigationController()
        
    let settingVC = SettingViewController(viewModel: SettingViewModel())
        .configureTabBarItem(title: "설정", image: UIImage(resource: .gear))
        .embedNavigationController()
    
    
    // MARK: View Life Cycle

    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .systemBackground
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = .label
        tabBarAppearance.barTintColor = .black
        tabBarAppearance.isTranslucent = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("🔥 ", self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [homeVC, calendarVC, settingVC]
    }
}

extension UIViewController {
    func configureTabBarItem(title: String, image: UIImage?) -> UIViewController {
        self.tabBarItem.title = title
        self.tabBarItem.image = image
        return self
    }
}


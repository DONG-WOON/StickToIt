//
//  SettingViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//

import Foundation
import RxSwift

final class SettingViewModel {
    
    enum Setting {
        enum Section: Int, CaseIterable {
            case first
            case second
            
            var header: String {
                switch self {
                case .first:
                    return StringKey.personalSetting.localized()
                case .second:
                    return StringKey.appInfo.localized()
                }
            }
            
            var rows: [String] {
                switch self {
                case .first:
                    return [StringKey.editNickname.localized(), StringKey.dataManagement.localized()]
                case .second:
                    return [StringKey.versionInfo.localized()]
                }
            }
            
            enum Row: String {
                case editNickname
//                case notification
                case dataManagement
                case openSource
                case versionInfo
            }
        }
    }
    
    var numberOfSections: Int {
        Setting.Section.allCases.count
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        Setting.Section(rawValue: section)?.header
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        if let section = Setting.Section(rawValue: section) {
            return section.rows.count
        } else {
            return 0
        }
    }
    
    func rowTitle(at indexPath: IndexPath) -> String? {
        if let section = Setting.Section(rawValue: indexPath.section) {
            return section.rows[indexPath.row]
        } else {
            return nil
        }
    }
    
    func isFirstSection(at indexPath: IndexPath) -> Bool {
        indexPath.section == 0
    }
    
    func isVersionInfo(at indexPath: IndexPath) -> Bool {
        indexPath == IndexPath(row: 0, section: 1)
    }
    
    func selectedRowAt(_ indexPath: IndexPath, completion: (Setting.Section.Row) -> Void) {
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            completion(.editNickname)
//        case IndexPath(row: 1, section: 0):
//            completion(.notification)
        case IndexPath(row: 1, section: 0):
            completion(.dataManagement)
        default:
            return
        }
    }
}

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
                    return "개인 설정"
                case .second:
                    return "앱 정보"
                }
            }
            
            var rows: [String] {
                switch self {
                case .first:
                    return ["닉네임 변경", "데이터 관리"]
                case .second:
                    return ["오픈소스", "버전정보"]
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
        indexPath == IndexPath(row: 1, section: 1)
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

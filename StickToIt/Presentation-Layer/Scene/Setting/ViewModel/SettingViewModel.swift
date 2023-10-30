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
                    return ["닉네임 변경", "알림 설정", "데이터 관리"]
                case .second:
                    return ["공지사항", "버전정보"]
                }
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
        indexPath.row == 1
    }
}

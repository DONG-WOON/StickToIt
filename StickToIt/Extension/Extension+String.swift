//
//  Extension+String.swift
//  StickToIt
//
//  Created by 서동운 on 10/31/23.
//

import Foundation

public extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "\(self)", comment: "")
    }
    
    func localized(with value: String) -> String {
        return String(format: self.localized(), value)
    }
}

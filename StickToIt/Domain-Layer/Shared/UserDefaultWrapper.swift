//
//  UserDefaultWrapper.swift
//  StickToIt
//
//  Created by 서동운 on 10/16/23.
//

import Foundation

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: Const.Key
    let type: T.Type
    let defaultValue: T?
    
    private let userDefaults = UserDefaults.standard
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    var wrappedValue: T? {
        get {
            guard let data = userDefaults.data(forKey: key.rawValue) else {
                return defaultValue
            }
            
            do {
                let value = try decoder.decode(T.self, from: data)
                return value
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                let data = try encoder.encode(newValue)
                userDefaults.setValue(data, forKey: key.rawValue)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}



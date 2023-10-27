//
//  DatabaseError.swift
//  StickToIt
//
//  Created by 서동운 on 10/27/23.
//

import Foundation

enum DatabaseError: Error {
    case invalidDirectory
    case fetchAll
    case fetch
    case filteredFetch
    case update
    case delete
}

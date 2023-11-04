//
//  DatabaseError.swift
//  StickToIt
//
//  Created by 서동운 on 10/27/23.
//

import Foundation

enum DatabaseError: Error {
    case invalidDirectory
    case fetchAllError
    case fetchError
    case filteredFetchError
    case updateError
    case deleteError
}

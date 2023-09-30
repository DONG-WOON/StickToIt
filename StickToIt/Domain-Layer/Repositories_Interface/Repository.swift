//
//  Repository.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation

protocol Repository {
 
    init(
        networkService: NetworkService?,
        databaseManager: (some DatabaseManager)?
    )
}

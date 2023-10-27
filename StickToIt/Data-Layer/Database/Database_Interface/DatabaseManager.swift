//
//  DatabaseManager.swift
//  StickToIt
//
//  Created by 서동운 on 9/28/23.
//

import Foundation
import RealmSwift

protocol DatabaseManager {
    
    // MARK: Read
    func fetchAll<T: Object & Entity>(type: T.Type) -> Results<T>
    func fetch<T: Object & Entity>(type: T.Type, key: UUID) -> T?
    
    func filteredFetch<T: Object & Entity>(
        type: T.Type,
        _ filtered: (T) -> Bool
    ) -> [T]
    
    // MARK: Create
    func create<U: Model & Identifiable<UUID>, T: Object & Entity>(
        model: U,
        to entity: T.Type,
        onFailure: @Sendable @escaping (Error?) -> Void
    )
    
    // MARK: Update
    func update<U: Model & Identifiable<UUID>, T: Object & Entity>(
        entity: T.Type,
        matchingWith model: U,
        updateHandler: @escaping (T) -> Void,
        onFailure: @Sendable @escaping (Error?) -> Void
    )
    
    func update<T: Object & Entity>(
        entity: T.Type,
        key: UUID,
        updateHandler: @escaping (T) -> Void,
        onFailure: @Sendable @escaping (Error?) -> Void
    )
    
    // MARK: Delete
    func delete<U: Model & Identifiable<UUID>, T: Object & Entity>(
        entity: T.Type,
        matchingWith model: U,
        deleteHandler: @escaping (T) -> Void,
        onFailure: @escaping @Sendable (Error?) -> Void
    )
    
    func deleteAll()
}

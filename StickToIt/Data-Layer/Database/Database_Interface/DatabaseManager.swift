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
    func fetchAll<T: Object & Entity>(
        type: T.Type
    ) -> Results<T>
    
    func fetch<T: Object & Entity>(
        type: T.Type,
        key: UUID
    ) -> T?
    
    func filteredFetch<T: Object & Entity>(
        type: T.Type,
        _ filtered: (T) -> Bool
    ) -> [T]
    
    // MARK: Create
    func create<U: Model & Identifiable<UUID>, T: Object & Entity>(
        model: U,
        to entity: T.Type,
        onComplete: @Sendable @escaping (Error?) -> Void
    )
    
    // MARK: Update
    
    func update<T: Object & Entity>(
        entity: T.Type,
        key: UUID,
        updateHandler: @escaping (T) -> Void,
        onComplete: @Sendable @escaping (Error?) -> Void
    )
    
    // MARK: Delete
    func delete<T: Object & Entity>(
        entity: T.Type,
        key: UUID,
        deleteHandler: @escaping (Realm, T) -> Void,
        onComplete: @escaping @Sendable (Error?) -> Void
    )
    
    func delete<T: Object & Entity>(
        entity: T.Type,
        key: UUID,
        onComplete: @escaping @Sendable (Error?) -> Void
    )
    
    func deleteAll(onComplete: @escaping @Sendable (Error?) -> Void) 
}

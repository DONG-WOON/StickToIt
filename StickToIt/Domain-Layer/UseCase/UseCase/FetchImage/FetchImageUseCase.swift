//
//  FetchImageUseCaseImpl.swift
//  StickToIt
//
//  Created by 서동운 on 10/7/23.
//

import Foundation

protocol FetchImageUseCase: FetchService {
    
}

final class FetchImageUseCaseImpl: FetchImageUseCase {
    
    typealias Model = ImageAsset
    typealias Query = ImageQuery
    
    init() {
        
    }
    
    func fetchAll(completion: @escaping ([ImageAsset]) -> Void) {
    }
    
    func fetch(query: ImageQuery, completion: @escaping (ImageAsset) -> Void) {
    }
}

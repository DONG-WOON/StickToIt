//
//  EditImageViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/10/23.
//

import Foundation

final class EditImageViewModel<UseCase: EditImageUseCase> {
    
    private let useCase: UseCase
    
    init(useCase: UseCase) {
        
        self.useCase = useCase
    }
    
    func upload(data: Data?) {
        useCase.upload(data: data)
    }
}

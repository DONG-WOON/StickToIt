//
//  EditImageViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/10/23.
//

import Foundation
import RxSwift

final class EditImageViewModel {
    
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case ConfigureUI
    }
   
    private let output = PublishSubject<Output>()
    private let disposeBag = DisposeBag()
    
    func transform(input: PublishSubject<Input>) -> PublishSubject<Output> {
        input
            .subscribe(with: self) { _self, event in
                switch event {
                case .viewDidLoad:
                    _self.output.onNext(.ConfigureUI)
                }
            }
            .disposed(by: disposeBag)
        
        
        return output.asObserver()
    }
}

extension EditImageViewModel {
    
    func textViewShouldChanged(_ text: String?, in range: NSRange, word: String) -> Bool {
        guard let allText = text else { return true }
        
        let newlineCount = allText.components(separatedBy: "\n").count
        
        if newlineCount > 5 && text != "" {
            if text == "\n" {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    func filtered(_ text: String?) -> String {
        guard let text = text else { return String() }
        return String(text.prefix(70))
    }
}

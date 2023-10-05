//
//  BorderedView.swift
//  StickToIt
//
//  Created by 서동운 on 10/4/23.
//

import UIKit

class BorderedView<T: UIView>: UIView {
    
    let innerView = T()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(innerView)
    }
    
    private func setConstraints() {
        innerView.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide).inset(10)
        }
    }
    
}

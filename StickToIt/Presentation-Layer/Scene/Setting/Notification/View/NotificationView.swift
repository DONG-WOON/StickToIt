//
//  NotificationView.swift
//  StickToIt
//
//  Created by 서동운 on 11/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.estimatedRowHeight = UITableView.automaticDimension
        self.register(
            NotificationViewCell.self,
            forCellReuseIdentifier: NotificationViewCell.identifier
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}


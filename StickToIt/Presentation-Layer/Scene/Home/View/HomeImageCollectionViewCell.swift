//
//  HomeImageCollectionViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 9/27/23.
//

import UIKit

final class HomeImageCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func configure() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        label.textAlignment = .center
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        label.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}

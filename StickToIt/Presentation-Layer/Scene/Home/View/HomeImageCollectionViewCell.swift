//
//  HomeImageCollectionViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 9/27/23.
//

import UIKit

final class HomeImageCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    lazy var editImageButton = ResizableButton(
        image: UIImage(systemName: Const.Image.ellipsis),
        symbolSize: 20, scale: .large,
        tintColor: .label, action: editImageButtonAction
    )
    
    lazy var addImageButton = ResizableButton(
        image: UIImage(systemName: Const.Image.plus),
        symbolSize: 30, scale: .large,
        tintColor: .label, action: addImageButtonAction
    )
    
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

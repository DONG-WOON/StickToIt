//
//  HomeImageCollectionViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 9/27/23.
//

import UIKit

protocol HomeImageCollectionViewCellDelegate: AnyObject {
    func addImageButtonDidTapped()
    func editImageButtonDidTapped()
}

final class HomeImageCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    weak var delegate: HomeImageCollectionViewCellDelegate?
    
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
    
    private lazy var editImageButtonAction = UIAction { _ in
        self.delegate?.editImageButtonDidTapped()
    }
    
    private lazy var addImageButtonAction = UIAction { _ in
        self.delegate?.addImageButtonDidTapped()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        
//        editImageButton.isHidden = imageView.image == nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    private func configure() {
        contentView.addSubview(imageView)
        contentView.addSubview(editImageButton)
        contentView.addSubview(addImageButton)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        editImageButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(contentView).inset(10)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
    }
}

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
        symbolConfiguration: .init(scale: .large),
        tintColor: .label,
        target: self, action: #selector(editImageButtonAction)
        )
        
    
    lazy var addImageButton = ResizableButton(
        image: UIImage(systemName: Const.Image.plus),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self, action: #selector(addImageButtonAction)
        )
    
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
        
        self.bordered(cornerRadius: 20, borderWidth: 1, borderColor: .systemIndigo)
        
        contentView.addSubview(imageView)
        contentView.addSubview(editImageButton)
        contentView.addSubview(addImageButton)
        
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
            make.height.equalTo(contentView).multipliedBy(0.6)
        }
        
        editImageButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.trailing.equalTo(contentView).inset(15)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
    }
}

extension HomeImageCollectionViewCell {
    
    @objc private func editImageButtonAction() {
        self.delegate?.editImageButtonDidTapped()
    }
    
    @objc private func addImageButtonAction() {
        self.delegate?.addImageButtonDidTapped()
    }
    
}

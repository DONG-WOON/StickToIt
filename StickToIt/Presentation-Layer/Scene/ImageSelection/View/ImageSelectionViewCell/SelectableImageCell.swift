//
//  SelectableImageCell.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import UIKit

final class SelectableImageCell: UICollectionViewCell {
    
    var cellIsSelected: Bool = false {
        didSet {
            select(isSelected: cellIsSelected)
        }
    }
    
    // MARK: UI Properties
    
    let imageView = UIImageView(backgroundColor: .systemBackground)
    let checkmark: UIImageView = {
        let view = UIImageView(
            image: UIImage(resource: .uncheckedCircle)
        )
        view.tintColor = .gray
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellIsSelected = false
    }

    func select(isSelected: Bool) {
        if isSelected {
            contentView.bordered(borderWidth: 1.5, borderColor: .systemIndigo)
            checkmark.image = UIImage(resource: .checkedCircle)
            checkmark.tintColor = .systemIndigo
        } else {
            contentView.bordered(borderWidth: 0.3, borderColor: .gray)
            checkmark.image = UIImage(resource: .uncheckedCircle)
            checkmark.tintColor = .gray
        }
    }
}

extension SelectableImageCell {
    private func configureViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(checkmark)
        
        contentView.bordered(borderWidth: 0.3, borderColor: .gray)
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        checkmark.snp.makeConstraints { make in
            make.top.trailing.equalTo(contentView).inset(7)
            make.size.equalTo(contentView).multipliedBy(0.15)
        }
    }
}

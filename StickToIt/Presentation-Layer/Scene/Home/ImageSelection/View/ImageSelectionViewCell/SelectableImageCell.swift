//
//  SelectableImageCell.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import UIKit

final class SelectableImageCell: UICollectionViewCell {
    
    // MARK: UI Properties
    
    let imageView: UIImageView = {
        let view = UIImageView(backgroundColor: .clear)
        view.contentMode = .scaleAspectFill
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
        
        imageView.image = nil
    }

    func select(isSelected: Bool) {
        if isSelected {
            contentView.bordered(borderWidth: 1.5, borderColor: .assetColor(.accent1))
        } else {
            contentView.bordered(borderWidth: 0.3, borderColor: .gray)
        }
    }
}

extension SelectableImageCell {
    private func configureViews() {
        contentView.addSubview(imageView)
        contentView.bordered(borderWidth: 0.3, borderColor: .gray)
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}

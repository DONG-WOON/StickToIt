//
//  CalendarCollectionViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//

import UIKit

final class CalendarCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.bordered(borderWidth: 0.5)
        return view
    }()
    
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
    
    func updateImage(_ data: Data) {
        imageView.image = UIImage(data: data)
    }
}

extension CalendarCollectionViewCell {
    private func configureViews() {
        contentView.addBlurEffect(.assetColor(.accent4).withAlphaComponent(0.3))
        contentView.rounded()
        contentView.addSubview(imageView)
    }
    
    private func setConstraints() {
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}

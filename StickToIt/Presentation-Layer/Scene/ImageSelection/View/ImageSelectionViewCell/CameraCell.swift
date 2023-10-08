//
//  CameraCell.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import UIKit

final class CameraCell: UICollectionViewCell {
    
    // MARK: UI Properties
    
    let cameraImageView: UIImageView = {
        var view  = UIImageView(backgroundColor: .systemBackground)
        view.image = UIImage(resource: .camera)
        view.tintColor = .label
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
    }
}

extension CameraCell {
    private func configureViews() {
        contentView.bordered(borderWidth: 1, borderColor: .gray)
        contentView.addSubview(cameraImageView)
    }
    
    private func setConstraints() {
        cameraImageView.snp.makeConstraints { make in
            make.center.equalTo(contentView)
            make.width.height.equalTo(contentView).multipliedBy(0.5)
        }
    }
}

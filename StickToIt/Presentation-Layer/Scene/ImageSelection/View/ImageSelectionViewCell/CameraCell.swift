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
    
    let cameralabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .semibold)
        view.tintColor = .label
        view.textAlignment = .center
        view.text = "사진 찍기"
        view.numberOfLines = 1
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
        contentView.addSubview(cameralabel)
        
    }
    
    private func setConstraints() {
        cameraImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView).inset(40)
        }
        cameralabel.snp.makeConstraints { make in
            make.top.equalTo(cameraImageView.snp.bottom).offset(10)
            make.bottom.horizontalEdges.equalTo(contentView).inset(25)
            make.height.equalTo(30)
        }
        
    }
}

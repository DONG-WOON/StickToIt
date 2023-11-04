//
//  CalendarCollectionViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//

import UIKit


final class CalendarCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: ImageCellDelegate?
    
    var dayPlan: DayPlan?
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.bordered(borderWidth: 0.5)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageDidTapped)))
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
    
    @objc func imageDidTapped() {
        guard let dayPlan else { return }
        delegate?.imageDidSelected(dayPlan)
    }
}

extension CalendarCollectionViewCell {
    private func configureViews() {
        contentView.addBlurEffect(.assetColor(.accent4).withAlphaComponent(0.3))
        contentView.bordered(borderWidth: 0.5, borderColor: .assetColor(.accent1))
        contentView.addSubview(imageView)
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}

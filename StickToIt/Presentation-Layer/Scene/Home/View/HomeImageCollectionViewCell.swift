//
//  HomeImageCollectionViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 9/27/23.
//

import UIKit

protocol HomeImageCollectionViewCellDelegate: AnyObject {
    func addImageButtonDidTapped(_ week: Week)
    func editImageButtonDidTapped(_ week: Week)
}

final class HomeImageCollectionViewCell: UICollectionViewCell {
    
    private var week: Week = .monday
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.borderColor = UIColor.systemIndigo.cgColor
        view.layer.borderWidth = 0.4
        return view
    }()
    
    let label: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.font = .systemFont(ofSize: 17)
        view.innerView.textColor = .label
        view.backgroundColor = .tertiaryLabel.withAlphaComponent(0.1)
        return view
    }()
    
    weak var delegate: HomeImageCollectionViewCellDelegate?
    
    lazy var editImageButton = ResizableButton(
        image: UIImage(resource: .ellipsis),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label,
        target: self, action: #selector(editImageButtonAction)
        )
        
    
    lazy var addImageButton = ResizableButton(
        image: UIImage(resource: .plus),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self, action: #selector(addImageButtonAction)
        )
    
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
    
    // MARK: Methods
    
    func updateUI(dayOfWeek: Week) {
        self.week = dayOfWeek
        label.innerView.text = dayOfWeek.kor
    }
    
    func update(data: DayPlan) {
        
        setBorder(data.isRequired)
        
        guard let imageData = data.imageData else { return }
        imageView.image = UIImage(data: imageData)
    }
    
    func setBorder(_ isTrue: Bool) {
        
        if isTrue {
            self.bordered(cornerRadius: 20, borderWidth: 2, borderColor: .systemIndigo)
        } else {
            self.bordered(cornerRadius: 20, borderWidth: 1, borderColor: .systemIndigo)
        }
    }
}

extension HomeImageCollectionViewCell {
    
    @objc private func editImageButtonAction() {
        self.delegate?.editImageButtonDidTapped(week)
    }
    
    @objc private func addImageButtonAction() {
        self.delegate?.addImageButtonDidTapped(week)
    }
}

extension HomeImageCollectionViewCell {
    private func configureViews() {
        
        self.bordered(cornerRadius: 20, borderWidth: 1, borderColor: .systemIndigo)
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(editImageButton)
        contentView.addSubview(addImageButton)
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
            make.height.equalTo(contentView).multipliedBy(0.8)
        }
        
        label.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView)
            
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

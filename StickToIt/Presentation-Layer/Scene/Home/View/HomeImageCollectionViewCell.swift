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
    
    let dayNameLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.font = .systemFont(ofSize: 17)
        view.innerView.textColor = .label
        view.innerView.setGradient(color1: .tertiaryLabel.withAlphaComponent(0.1), color2: .clear, startPoint: .init(x: 0, y: 0), endPoint: .init(x: 1, y: 1))
        return view
    }()
    
    lazy var requiredLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.text = "Required"
        view.innerView.textColor = .white
        view.innerView.textAlignment = .center
        view.rounded(cornerRadius: 15)
        view.backgroundColor = .systemIndigo.withAlphaComponent(0.6)
        return view
    }()
    
//    let checkMarkImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.backgroundColor = .clear
//        imageView.tintColo
//        imageView.image = UIImage(resource: .checkedCircle)
//        return imageView
//    }()
    
    weak var delegate: HomeImageCollectionViewCellDelegate?
    
    lazy var editImageButton: ResizableButton = {
        let button = ResizableButton(
            image: UIImage(resource: .ellipsis),
            symbolConfiguration: .init(scale: .large),
            tintColor: .label,
            target: self, action: #selector(editImageButtonAction)
        )
        button.backgroundColor = .clear
        return button
    }()
    
    lazy var addImageButton: ResizableButton = {
        let button = ResizableButton(
            image: UIImage(resource: .plus),
            symbolConfiguration: .init(scale: .large),
            tintColor: .label, target: self, action: #selector(addImageButtonAction)
        )
        button.backgroundColor = .clear
        return button
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
        requiredLabel.isHidden = true
        dayNameLabel.innerView.textColor = .label
        dayNameLabel.innerView.text = nil
        addImageButton.isHidden = false
        editImageButton.tintColor = .label
    }
    
    // MARK: Methods
    
    func updateUI(dayOfWeek: Week) {
        self.week = dayOfWeek
        if dayOfWeek == .none {
            dayNameLabel.innerView.text = "옵션"
            requiredLabel.isHidden = true
        } else {
            dayNameLabel.innerView.text = dayOfWeek.kor
            requiredLabel.isHidden = false
        }
    }
    
    func update(imageData: Data?) {
        guard let imageData = imageData else { return }
        addImageButton.isHidden = true
        imageView.image = UIImage(data: imageData)
    }
    
    func update(dayPlan: DayPlan) {
        
        checkDayPlanIsRequired(dayPlan.isRequired)
    }
    
    func checkDayPlanIsRequired(_ isRequired: Bool) {
    
        requiredLabel.isHidden = !isRequired
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
        contentView.addSubview(requiredLabel)
        contentView.addSubview(dayNameLabel)
        contentView.addSubview(editImageButton)
        contentView.addSubview(addImageButton)
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
            make.height.equalTo(contentView).multipliedBy(0.8)
        }
        
        dayNameLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView)
        }
        
        requiredLabel.snp.makeConstraints { make in
            make.bottom.equalTo(imageView).offset(-5)
            make.leading.equalTo(contentView).inset(5)
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

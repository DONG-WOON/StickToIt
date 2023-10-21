//
//  HomeImageCollectionViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 9/27/23.
//

import UIKit

protocol HomeImageCollectionViewCellDelegate: AnyObject {
    func imageDidSelected(_ dayPlan: DayPlan)
}

final class HomeImageCollectionViewCell: UICollectionViewCell {
    
    var dayPlan: DayPlan? {
        didSet {
            guard let dayPlan else { return }
            update(with: dayPlan)
        }
    }
    
//    private let slideButton = SlideActionButton()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.rounded(cornerRadius: 20)
        view.backgroundColor = .assetColor(.accent4).withAlphaComponent(0.3)
        return view
    }()
    
    private lazy var blurView: BlurEffectView = {
        let view = BlurEffectView()
        view.rounded(cornerRadius: 20)
        return view
    }()
    
    private let dayNameLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.font = .systemFont(ofSize: 19, weight: .semibold)
        view.innerView.textColor = .white
        return view
    }()
    
    private lazy var requiredLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.text = "필수"
        view.innerView.textColor = .white
        view.innerView.textAlignment = .center
        view.rounded(cornerRadius: 16)
        view.backgroundColor = .assetColor(.accent2)
        return view
    }()
    
    private let checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.tintColor = .systemGreen
        imageView.image = UIImage(resource: .checkedCircle)
        imageView.isHidden = true
        return imageView
    }()
    
    weak var delegate: HomeImageCollectionViewCellDelegate?
    
    lazy var placeholderImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "Placeholder"))
        view.backgroundColor = .clear
        view.contentMode = .scaleToFill
        view.tintColor = .label
        return view
    }()
    
    private lazy var imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageDidSelected))
    
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
        
        dayPlan = nil
        imageView.image = nil
        checkMarkImageView.isHidden = true
        requiredLabel.isHidden = true
        dayNameLabel.innerView.text = nil
        placeholderImageView.isHidden = false
    }
    
    // MARK: Methods
    
    func update(imageData: Data?) {
        guard let imageData = imageData else { return }
        placeholderImageView.isHidden = true
        imageView.image = UIImage(data: imageData)
    }
    
    private func update(with dayPlan: DayPlan) {
        if let _date = dayPlan.date {
            dayNameLabel.innerView.text = DateFormatter.getFullDateString(from: _date)
        }
        requiredLabel.isHidden = !dayPlan.isRequired

        checkMarkImageView.isHidden = !dayPlan.isComplete
        
//        if dayPlan.isComplete {
//            slideButton.complete()
//        } else {
//            slideButton.reset()
//        }
    }
    
}

extension HomeImageCollectionViewCell {
    
    @objc private func imageDidSelected() {
        guard let dayPlan else { return }
        self.delegate?.imageDidSelected(dayPlan)
    }
}

extension HomeImageCollectionViewCell {
    private func configureViews() {
        
        self.backgroundColor = .assetColor(.accent4)
        self.rounded(cornerRadius: 20)
        self.addBlurEffect()
        
        contentView.addSubview(placeholderImageView)
        contentView.addSubview(imageView)
        contentView.addSubview(blurView)
//        contentView.addSubview(slideButton)
        
        blurView.addSubview(requiredLabel)
        blurView.addSubview(dayNameLabel)
        blurView.addSubview(checkMarkImageView)
        
        contentView.addGestureRecognizer(imageTapGesture)
    }
    
    private func setConstraints() {
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(4)
            make.horizontalEdges.equalTo(blurView)
        }
        
        placeholderImageView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.width.equalTo(contentView).multipliedBy(0.3)
            make.height.equalTo(placeholderImageView.snp.width)
        }
        
        blurView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.horizontalEdges.bottom.equalTo(contentView).inset(4)
            make.height.equalTo(50)
        }
        
        dayNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(blurView)
            make.leading.equalTo(blurView).inset(10)
        }
        
        requiredLabel.snp.makeConstraints { make in
            make.top.trailing.bottom.equalTo(blurView).inset(4)
        }
        
        checkMarkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(blurView)
            make.leading.equalTo(dayNameLabel.snp.trailing).offset(15)
        }
        
//        slideButton.snp.makeConstraints { make in
//            make.horizontalEdges.equalTo(contentView).inset(3)
//            make.height.equalTo(50)
//            make.bottom.equalTo(contentView).inset(3)
//        }
    }
}

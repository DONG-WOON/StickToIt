//
//  HomeImageCollectionViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 9/27/23.
//

import UIKit

protocol HomeImageCollectionViewCellDelegate: AnyObject {
    func addImageButtonDidTapped(_ dayPlan: DayPlan)
    func editImageButtonDidTapped(_ dayPlan: DayPlan)
}

final class HomeImageCollectionViewCell: UICollectionViewCell {
    
    var dayPlan: DayPlan? {
        didSet {
            guard let dayPlan else { return }
            update(with: dayPlan)
        }
    }
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.borderColor = UIColor.systemIndigo.cgColor
        view.layer.borderWidth = 0.4
        view.rounded(cornerRadius: 20)
        return view
    }()
    
    lazy var blurView: BlurEffectView = {
        let view = BlurEffectView()
        view.rounded(cornerRadius: 20)
        return view
    }()
    
    let dayNameLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.font = .systemFont(ofSize: 19, weight: .semibold)
        view.innerView.textColor = .white
        return view
    }()
    
    lazy var requiredLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.text = "필수"
        view.innerView.textColor = .white
        view.innerView.textAlignment = .center
        view.rounded(cornerRadius: 16)
        view.backgroundColor = .systemIndigo.withAlphaComponent(0.6)
        return view
    }()
    
    let checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.tintColor = .systemGreen
        imageView.image = UIImage(resource: .checkedCircle)
        imageView.isHidden = true
        return imageView
    }()
    
    weak var delegate: HomeImageCollectionViewCellDelegate?
    
    lazy var editImageButton: ResizableButton = {
        let button = ResizableButton(
            image: UIImage(resource: .ellipsis),
            symbolConfiguration: .init(scale: .large),
            tintColor: .white,
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
        checkMarkImageView.isHidden = true
        requiredLabel.isHidden = true
        dayNameLabel.innerView.text = nil
        addImageButton.isHidden = false
    }
    
    // MARK: Methods
    
    func update(imageData: Data?) {
        guard let imageData = imageData else { return }
        addImageButton.isHidden = true
        imageView.image = UIImage(data: imageData)
    }
    
    private func update(with dayPlan: DayPlan) {
        dayNameLabel.innerView.text = DateFormatter.getFullDateString(from: dayPlan.date)
        requiredLabel.isHidden = !dayPlan.isRequired
        checkDayPlanIsRequired(dayPlan.isRequired)
        checkMarkImageView.isHidden = !dayPlan.isComplete
    }
    
    func checkDayPlanIsRequired(_ isRequired: Bool) {
        
        requiredLabel.isHidden = !isRequired
    }
}

extension HomeImageCollectionViewCell {
    
    @objc private func editImageButtonAction() {
        guard let dayPlan else { return }
        self.delegate?.editImageButtonDidTapped(dayPlan)
    }
    
    @objc private func addImageButtonAction() {
        guard let dayPlan else { return }
        self.delegate?.addImageButtonDidTapped(dayPlan)
    }
}

extension HomeImageCollectionViewCell {
    private func configureViews() {
        
        self.bordered(cornerRadius: 20, borderWidth: 0.5, borderColor: .systemIndigo)
        
        self.setGradient(
            color1: .init(red: 95/255, green: 193/255, blue: 220/255, alpha: 1).withAlphaComponent(0.5),
            color2: .systemIndigo.withAlphaComponent(0.5),
            startPoint: .init(x: 1, y: 0),
            endPoint: .init(x: 1, y: 1)
        )
        
        contentView.addSubview(imageView)
        contentView.addSubview(blurView)
        contentView.addSubview(requiredLabel)
        contentView.addSubview(addImageButton)
        
        blurView.addSubview(dayNameLabel)
        blurView.addSubview(editImageButton)
        blurView.addSubview(checkMarkImageView)
        
        }
    
    private func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        blurView.snp.makeConstraints { make in
            make.bottom.equalTo(contentView).inset(15)
            make.horizontalEdges.equalTo(contentView).inset(15)
            make.height.equalTo(50)
        }
        
        dayNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(blurView)
            make.leading.equalTo(blurView).inset(10)
        }
        
        requiredLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView).inset(5)
            make.leading.equalTo(imageView).inset(5)
        }
        
        checkMarkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(blurView)
            make.leading.equalTo(dayNameLabel.snp.trailing).offset(15)
        }
        
        editImageButton.snp.makeConstraints { make in
            make.trailing.equalTo(blurView).inset(10)
            make.centerY.equalTo(blurView)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.center.equalTo(imageView)
        }
    }
}

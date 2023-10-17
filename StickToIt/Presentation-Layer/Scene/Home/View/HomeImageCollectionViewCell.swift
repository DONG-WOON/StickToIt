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
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.borderColor = UIColor.systemIndigo.cgColor
        view.layer.borderWidth = 0.4
        view.rounded(cornerRadius: 20)
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
        view.backgroundColor = .systemIndigo.withAlphaComponent(0.6)
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
    
    lazy var addImageView: UIImageView = {
        let view = UIImageView(image: UIImage(resource: .plus))
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
        addImageView.isHidden = false
    }
    
    // MARK: Methods
    
    func update(imageData: Data?) {
        guard let imageData = imageData else { return }
        addImageView.isHidden = true
        imageView.image = UIImage(data: imageData, scale: 0.6)
    }
    
    private func update(with dayPlan: DayPlan) {
        if let _date = dayPlan.date {
            dayNameLabel.innerView.text = DateFormatter.getFullDateString(from: _date)
        }
        imageView.contentMode = dayPlan.imageContentIsFill ? .scaleAspectFill : .scaleAspectFit
        requiredLabel.isHidden = !dayPlan.isRequired
        checkDayPlanIsRequired(dayPlan.isRequired)
        checkMarkImageView.isHidden = !dayPlan.isComplete
    }
    
    func checkDayPlanIsRequired(_ isRequired: Bool) {
        
        requiredLabel.isHidden = !isRequired
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
        
        self.bordered(cornerRadius: 20, borderWidth: 0.5, borderColor: .systemIndigo)
        
        contentView.addSubview(addImageView)
        contentView.addSubview(imageView)
        contentView.addSubview(blurView)
        contentView.addSubview(requiredLabel)
        
        blurView.addSubview(dayNameLabel)
        blurView.addSubview(checkMarkImageView)
        
        contentView.addGestureRecognizer(imageTapGesture)
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        addImageView.snp.makeConstraints { make in
            make.center.equalTo(contentView)
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
    }
}

//
//  HomeImageCollectionViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 9/27/23.
//

import UIKit

protocol ImageCellDelegate: AnyObject {
    func imageDidSelected(_ dayPlan: DayPlan)
}

final class HomeImageCollectionViewCell: UICollectionViewCell {
    
    var dayPlan: DayPlan? {
        didSet {
            guard let dayPlan else { return }
            update(with: dayPlan)
        }
    }
    
    private let todayLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.text = StringKey.today.localized()
        view.backgroundColor = .assetColor(.accent1)
        view.innerView.textColor = .white
        view.rounded()
        view.isHidden = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.rounded()
        return view
    }()
    
    private lazy var blurView: BlurEffectView = {
        let view = BlurEffectView()
        view.rounded()
        return view
    }()
    
    private let dayNameLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.innerView.font = .systemFont(ofSize: 19, weight: .semibold)
        view.innerView.textColor = .white
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
    
    weak var delegate: ImageCellDelegate?
    
    lazy var placeholderImageView: UIImageView = {
        let view = UIImageView(image: UIImage(asset: .placeholder))
        view.backgroundColor = .clear
        view.contentMode = .scaleToFill
        view.tintColor = .label
        return view
    }()
    
    private lazy var weekDayLabel: PaddingView<UILabel> = {
       let paddingView = PaddingView<UILabel>()
        paddingView.innerView.text = StringKey.week.localized(with: "1")
        paddingView.innerView.font = .monospacedSystemFont(ofSize: Const.FontSize.body, weight: .semibold)
        paddingView.innerView.backgroundColor = .clear
        paddingView.backgroundColor = .assetColor(.accent4)
        paddingView.rounded(cornerRadius: 20)
        paddingView.addBlurEffect()
        return paddingView
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
        dayNameLabel.innerView.text = nil
        placeholderImageView.isHidden = false
        todayLabel.isHidden = true
    }
    
    // MARK: Methods
    
    func update(imageData: Data?) {
        guard let imageData = imageData else { return }
        placeholderImageView.isHidden = true
        imageView.image = UIImage(data: imageData)
    }
    
    private func update(with dayPlan: DayPlan) {
        dayNameLabel.innerView.text = DateFormatter.getFullDateString(from: dayPlan.date)
        checkMarkImageView.isHidden = !dayPlan.isComplete
        if DateFormatter.getFullDateString(from: dayPlan.date) < DateFormatter.getFullDateString(from: .now) {
            todayLabel.isHidden = false
            todayLabel.backgroundColor = .systemGray2
            todayLabel.innerView.text = StringKey.certificationFailed.localized()
        } else if Calendar.current.isDateInToday(dayPlan.date) {
            todayLabel.innerView.text = StringKey.today.localized()
            todayLabel.isHidden = false
        } else {
            todayLabel.isHidden = true
        }
        
        weekDayLabel.innerView.text = StringKey.week.localized(with: "\(dayPlan.week)")
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
        
        contentView.addBlurEffect(.assetColor(.accent4))
        contentView.rounded()
        
        contentView.addSubviews(
            [placeholderImageView, imageView, blurView, weekDayLabel]
        )
        
        blurView.addSubviews(
            [dayNameLabel, checkMarkImageView, todayLabel]
        )

        contentView.addGestureRecognizer(imageTapGesture)
    }
    
    private func setConstraints() {
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(4)
            make.horizontalEdges.equalTo(contentView).inset(4)
        }
        
        weekDayLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).inset(10)
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
            make.leading.equalTo(blurView).inset(0)
        }
        
        checkMarkImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(blurView)
            make.leading.equalTo(dayNameLabel.snp.trailing).offset(5)
        }
        
        todayLabel.snp.makeConstraints { make in
            make.centerY.equalTo(blurView)
            make.leading.lessThanOrEqualTo(checkMarkImageView.snp.trailing)
            make.trailing.equalTo(blurView.snp.trailing).inset(5)
        }
    }
}

//
//  CreatePlanView.swift
//  StickToIt
//
//  Created by 서동운 on 10/3/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol CalendarButtonProtocol: AnyObject {
    func endDateSettingButtonDidTapped()
}

protocol DayCellDelegate: AnyObject {
    func select(week: Week?)
    func deSelect(week: Week?)
}

final class CreatePlanView: UIScrollView {
    
    weak var buttonDelegate: CalendarButtonProtocol?
    weak var dayCellDelegate: DayCellDelegate?
    
    let planNameLabel: UILabel = {
        let view = UILabel()
        view.text = "목표"
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    let planNameMaximumTextNumberLabel: UILabel = {
        let view = UILabel()
        view.text = "0 / 20"
        view.textColor = .tertiaryLabel
        view.font = .boldSystemFont(ofSize: 15)
        return view
    }()
    
    let planNameTextField: BorderedTextField = {
        let view = BorderedTextField(
            cornerRadius: 10, borderWidth: 0.5,
            borderColor: .systemIndigo
        )
        view.placeholder = "ex) 달리기 100주"
        return view
    }()
    
    let planTargetPeriodLabel: UILabel = {
        let view = UILabel()
        view.text = "목표 기간 설정 (최소 3일!)"
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()

    let endDateLabel: PaddingView<UILabel> = {
        let view = PaddingView<UILabel>()
        view.bordered(cornerRadius: 10, borderWidth: 0.7, borderColor: .systemIndigo)
        view.innerView.text = "종료일을 설정해주세요 ---->"
        view.innerView.backgroundColor = .clear
        view.innerView.textColor = .label
        return view
    }()
    
    lazy var endDateSettingButton: ResizableButton = {
        let button = ResizableButton(
            image: UIImage(resource: .calendar),
            symbolConfiguration: .init(scale: .large),
            tintColor: .white,
            backgroundColor: .systemIndigo.withAlphaComponent(0.6),
            target: self,
            action: #selector(endDateSettingButtonDidTapped)
        )
        return button
    }()
    
    let planRequiredDoingDayLabel: UILabel = {
        let view = UILabel()
        view.text = "목표 실행일 설정"
        view.textColor = .label
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    let executionDaysOfWeekdayCollectionView = ExecutionDayCollectionView()
    
    let descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.text = " - 목표 시작일은 목표 생성일 이후 날짜로 설정할 수 있습니다.\n\n - 목표 기간 설정을 하지않으면 기본 3일로 설정됩니다.\n\n - 목표 실행일은 기본적으로 주5일 (월~금)으로 설정됩니다."
        view.textColor = .label
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    let createButton: UIButton = {
        let view = UIButton()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    @objc func endDateSettingButtonDidTapped() {
        buttonDelegate?.endDateSettingButtonDidTapped()
    }
    
    func update(plan: Plan) {
        planNameLabel.text = plan.name
        plan.executionDaysOfWeekday.forEach { week in
            let cell = executionDaysOfWeekdayCollectionView.cellForItem(at: IndexPath(item: week.rawValue - 1, section: 0)) as? ExecutionDayCollectionViewCell 
            
            cell?.isSelected = true
        }
        
        endDateLabel.innerView.text = "종료일: \(DateFormatter.getFullDateString(from: plan.endDate))"
    }
}

extension CreatePlanView {
    
    private func configureViews() {
        
        executionDaysOfWeekdayCollectionView.dataSource = self
        executionDaysOfWeekdayCollectionView.delegate = self
        executionDaysOfWeekdayCollectionView.register(ExecutionDayCollectionViewCell.self, forCellWithReuseIdentifier: ExecutionDayCollectionViewCell.identifier)
        
        addSubview(planNameLabel)
        addSubview(planNameTextField)
        addSubview(planNameMaximumTextNumberLabel)
        addSubview(planTargetPeriodLabel)
        addSubview(endDateLabel)
        addSubview(planRequiredDoingDayLabel)
        addSubview(executionDaysOfWeekdayCollectionView)
        
        addSubview(descriptionLabel)
        addSubview(createButton)
       
        endDateLabel.addSubview(endDateSettingButton)
    }
    
    private func setConstraints() {
        
        self.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(self.frameLayoutGuide.snp.width)
        }
        
        planNameLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        planNameMaximumTextNumberLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentLayoutGuide).inset(20)
            make.bottom.equalTo(planNameTextField.snp.top).offset(-10)
        }
        
        planNameTextField.snp.makeConstraints { make in
            make.top.equalTo(planNameLabel.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        planTargetPeriodLabel.snp.makeConstraints { make in
            make.top.equalTo(planNameTextField.snp.bottom).offset(30)
            make.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        endDateLabel.snp.makeConstraints { make in
            make.top.equalTo(planTargetPeriodLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
            make.size.equalTo(planNameTextField)
        }
        
        endDateSettingButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(endDateSettingButton.snp.height)
        }
        
        planRequiredDoingDayLabel.snp.makeConstraints { make in
            make.top.equalTo(endDateLabel.snp.bottom).offset(50)
            make.leading.equalTo(self.contentLayoutGuide).inset(20)
        }
        
        executionDaysOfWeekdayCollectionView.snp.makeConstraints { make in
            make.top.equalTo(planRequiredDoingDayLabel.snp.bottom)
            
            let inset = 20.0
            let deviceWidth = UIScreen.main.bounds.width
            
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(inset)
            make.height.equalTo((deviceWidth - (inset * 2) - (3 * 6)) / 7)
        }
        
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(executionDaysOfWeekdayCollectionView.snp.bottom).offset(50)
            make.horizontalEdges.equalTo(self.contentLayoutGuide).inset(20)
            make.bottom.equalTo(contentLayoutGuide).offset(-10)
        }
    }
}

extension CreatePlanView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExecutionDayCollectionViewCell.identifier, for: indexPath) as? ExecutionDayCollectionViewCell else { return UICollectionViewCell() }
        cell.label.text = Week(rawValue: indexPath.item + 1)?.kor
        cell.isUserInteractionEnabled = false
        return cell
    }
}

extension CreatePlanView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dayCellDelegate?.select(week: Week(rawValue: indexPath.item + 1))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        dayCellDelegate?.deSelect(week: Week(rawValue: indexPath.item + 1))
    }
}

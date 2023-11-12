//
//  NotificationViewCell.swift
//  StickToIt
//
//  Created by 서동운 on 11/12/23.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let timePicker = UIDatePicker()
    private let notificationArrowSwitch = UISwitch()
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setUpPickerRow(time: Date?, dateChanged: @escaping (Date) -> Void) {
        titleLabel.text = StringKey.notiTimeTitle.localized()
        
        contentView.addSubview(timePicker)
        
        timePicker.datePickerMode = .time
        timePicker.tintColor = .assetColor(.accent1)
        timePicker.preferredDatePickerStyle = .inline
        
        if let time = time {
            timePicker.date = time
        }
        
        timePicker.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(20)
            make.centerY.equalTo(contentView)
        }
        
        timePicker.rx.date
            .skip(1)
            .bind(onNext: dateChanged)
            .disposed(by: disposeBag)
    }
    
    func setUpSwitchRow(isOn: Bool, switchChanged: @escaping (Bool) -> Void) {
        titleLabel.text = StringKey.notiSwitchTitle.localized()
    
        contentView.addSubview(notificationArrowSwitch)
        
        notificationArrowSwitch.onTintColor = .assetColor(.accent1)
        notificationArrowSwitch.isOn = isOn
        
        notificationArrowSwitch.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(25)
            make.centerY.equalTo(contentView)
        }
        
        notificationArrowSwitch.rx.isOn
            .bind(onNext: switchChanged)
            .disposed(by: disposeBag)
    }
    
    func update(date: Date, isAllowed: Bool) {
        timePicker.date = date
        notificationArrowSwitch.isOn = isAllowed
    }
}

extension NotificationViewCell: BaseViewConfigurable {
    func configureViews() {
        
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(titleLabel)
       
        titleLabel.font = .systemFont(ofSize: Const.FontSize.body)
        titleLabel.textColor = .label
    }
    
    func setConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).inset(20)
            make.top.equalTo(contentView).inset(20)
            make.bottom.equalTo(contentView).inset(20)
        }
    }
}

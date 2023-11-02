//
//  StickToItCalendar.swift
//  StickToIt
//
//  Created by 서동운 on 10/4/23.
//

import UIKit
import SnapKit
import FSCalendar

@objc protocol StickToItCalendarDelegate: AnyObject {
    func calendarView(didSelectAt date: Date)
    @objc optional func calendarWillDisplay(date: Date)
    @objc optional func numberOfEventsFor(date: Date) -> Int
    @objc optional func eventDefaultColorsFor(date: Date) -> [UIColor]?
    @objc optional func pageDidChange(on date: Date)
}

final class StickToItCalendar: UIView {
    
    // MARK: - Properties
    
    private var minimumDate: Date? { didSet { calendar.reloadData() } }
    private var maximumDate: Date? { didSet { calendar.reloadData() } }
    var currentDate: Date = Date.now
    
    private let calendar = FSCalendar()
    weak var delegate: StickToItCalendarDelegate?
    
    /// CalendarHeaderView
    private let customHeaderView = UIView(backgroundColor: .clear)
    
    private let monthLabel: UILabel = {
        let titleLabel = UILabel()

        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        return titleLabel
    }()
    
    private lazy var leftButton = ResizableButton(
        image: UIImage(resource: .chevronLeft),
        symbolConfiguration: .init(scale: .large), tintColor: .assetColor(.accent2),
        target: self, action: #selector(moveToPreviousMonth)
    )
    private lazy var rightButton = ResizableButton(
        image: UIImage(resource: .chevronRight),
        symbolConfiguration: .init(scale: .large), tintColor: .assetColor(.accent2),
        target: self, action: #selector(moveToNextMonth)
    )
    
    private let weekdaySeparator = UIView(backgroundColor: .tertiaryLabel)
    
    // MARK: - Life Cycle
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initCalendar()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func moveToPreviousMonth() {
        
        let currentPage = calendar.currentPage
        let previousPage = Calendar.current.date(byAdding: .month, value: -1, to: currentPage)!
        calendar.setCurrentPage(previousPage, animated: true)
    }

    @objc private func moveToNextMonth() {
        
        let currentPage = calendar.currentPage
        let previousPage = Calendar.current.date(byAdding: .month, value: +1, to: currentPage)!
        calendar.setCurrentPage(previousPage, animated: true)
    }
    
    // 해당날짜를 선택된 것으로 표시해주는 메소드
    func select(date: Date?) {
        guard let date = date else { return }
        monthLabel.text = DateFormatter.formatToString(format: .calendarHeader, from: date)
        calendar.select(date)
    }
    
    func setMaximumDate(_ date: Date?) {
        maximumDate = date
    }
    
    func setMinimumDate(_ date: Date?) {
        minimumDate = date
    }
    
    func reloadData() {
        calendar.reloadData()
    }
    
    private func initCalendar() {

        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.headerHeight = 0
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.locale = .current
        
        
//        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: CustomCalendarCell.identifier)
    }
    
    private func setCalendarWeekdayView() {
        
        calendar.weekdayHeight = 40
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 16)
        calendar.appearance.weekdayTextColor = .assetColor(.accent2)
    }
    
    private func setCalendarDaysView() {
        
        calendar.appearance.todayColor = .assetColor(.accent2)
        calendar.appearance.titleDefaultColor = .label
        calendar.appearance.titleTodayColor = .systemBackground
        calendar.appearance.titleFont = UIFont.boldSystemFont(ofSize: 16)
    }
    
    // MARK: - Configure
    
    private func configureViews() {
        
        setCalendarWeekdayView()
        setCalendarDaysView()
        
        addSubViewsWithConstraints()
    }
    
    // MARK: - Setting Constraints
    
    private func addSubViewsWithConstraints() {
        
        addSubview(customHeaderView)
        addSubview(calendar)
        
        calendar.calendarWeekdayView.addSubview(weekdaySeparator)
        
        customHeaderView.addSubview(monthLabel)
        customHeaderView.addSubview(leftButton)
        customHeaderView.addSubview(rightButton)
        
        monthLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(customHeaderView).inset(10)
            make.leading.equalTo(customHeaderView).inset(20)
        }
        
        leftButton.snp.makeConstraints { make in
            make.width.equalTo(leftButton.snp.height)
            make.centerY.equalTo(rightButton)
            make.trailing.equalTo(rightButton.snp.leading).offset(-5)
        }
        
        rightButton.snp.makeConstraints { make in
            make.width.equalTo(rightButton.snp.height)
            make.centerY.equalTo(customHeaderView)
            make.trailing.equalTo(customHeaderView).inset(20)
        }
        
        customHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        weekdaySeparator.snp.makeConstraints { make in
            make.leading.trailing.equalTo(calendar).inset(10)
            make.height.equalTo(1)
            make.bottom.equalTo(calendar.calendarWeekdayView.snp.bottom)
        }
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(customHeaderView.snp.bottom)
            make.bottom.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

// MARK: - FSCalendarDataSource

extension StickToItCalendar: FSCalendarDataSource {
    
    // 캘린더에서 볼수있는 미니멈 날짜
    func minimumDate(for calendar: FSCalendar) -> Date {
        if let minimumDate = minimumDate {
            return minimumDate
        } else {
            let now = Date()
            let tenYearsAgo = Calendar.current.date(byAdding: .year, value: -10, to: now)!
            return tenYearsAgo
        }
    }
    
    // 캘린더에서 볼수있는 맥시멈 날짜
    func maximumDate(for calendar: FSCalendar) -> Date {
        if let maximumDate = maximumDate {
            return maximumDate
        } else {
            let now = Date()
            let tenYearsLater = Calendar.current.date(byAdding: .year, value: 10, to: now)!
            return tenYearsLater
        }
    }
    
    // 이벤트 발생 날짜에 필요한 만큼 개수 반환 (최대 3개)
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return delegate?.numberOfEventsFor?(date: date) ?? 0
    }
}

// MARK: - FSCalendarDelegate

extension StickToItCalendar: FSCalendarDelegate {
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let today = calendar.currentPage
        monthLabel.text = DateFormatter.formatToString(format: .calendarHeader, from: today)
        delegate?.pageDidChange?(on: today)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        delegate?.calendarView(didSelectAt: date)
        
        // 현재 캘린더에서 보이는 이전달 또는 다음달의 날짜를 누르면 해당 달로 이동하도록 하는 부분
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }

    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        
        delegate?.calendarWillDisplay?(date: date)
    }
}
// MARK: - FSCalendarDelegateAppearance

extension StickToItCalendar: FSCalendarDelegateAppearance {

    // 스터디 스케쥴 북마크컬러에따라 컬러 지정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return delegate?.eventDefaultColorsFor?(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        
        return .assetColor(.accent1) // nil을 해주어도 blue로 설정되어있어서 clear로 해주어야 함.
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return .white // nil을 해주어도 white로 설정되어있어서 black로 해주어야 함.
    }
}

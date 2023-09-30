//
//  HomeViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel {

    private let showPlanUseCase: ShowPlanUseCase
    private let mainQueue: DispatchQueue
    
    var userPlanList = PublishSubject<[PlanQuery]>()
    var currentPlan = PublishSubject<Plan>()
    var currentWeeklyPlan = PublishSubject<WeeklyPlan>()
    var currentWeek = BehaviorSubject<Int>(value: 1)
    
    private var disposeBag = DisposeBag()
    
    init(
        showPlanUseCase: ShowPlanUseCase,
        mainQueue: DispatchQueue = .main
    ) {
        self.showPlanUseCase = showPlanUseCase
        self.mainQueue = mainQueue
         
//        showPlanUseCase.savePlan(Plan(title: "달리기", targetWeek: 1, startDate: Date()))
        // 레포로 부터 위클리 계획을 가져와
        // 계획이 있으면 이름을 리스트에 추가하고, 아닐경우 emptyView를 보여주거나, 생성화면으로 이동
        
        // 사용자가 장기간 앱을 사용하지않은경우 날짜가 지난지 어떻게 알것인지.
        // -> 포그라운드 상태에 진입할때 비동기로 몇주가 지났는지 확인?
        // -> 타이머 사용
    }
    
    // MARK: External method
    
    func viewDidLoad() {
        
        fetchWeeklyPlanQueries()
        userPlanList.subscribe(onNext: { queries in
            guard let query = queries.first else { return }
            self.fetchPlan(query)
        }, onError: { print($0) }, onCompleted: { print("complete") } )
        .disposed(by: disposeBag)
    }
    
    func reload() {
        
    }
    
    func fetchPlan(_ query: PlanQuery) {
        // 쿼리로 현재 플랜에 대한 정보 가져오기
        showPlanUseCase.fetchPlan(query: query) { plan in
            self.currentPlan.onNext(plan)
        }
    }
    
    func fetchWeeklyPlan(of week: Int) {
        currentPlan
            .map { $0.weeklyPlans }
            .map { weeklyPlans in
                weeklyPlans.first(where: { $0.week == week } )
            }
            .ifEmpty(default: nil)
            .subscribe(onNext: { weeklyPlan in
                guard let weeklyPlan else { return }
                self.currentWeeklyPlan.onNext(weeklyPlan)
            })
            .disposed(by: disposeBag)
    }
    
    func save(_ plan: Plan) {
        showPlanUseCase.savePlan(plan)
    }
    
    // MARK: internal Method
    
    private func fetchWeeklyPlanQueries() {
        showPlanUseCase.fetchAllPlans { [weak self] plans in
            let planQueries = plans.map {
                PlanQuery(planID: $0._id,
                          planName: $0.title)
            }
            self?.userPlanList.onNext(planQueries)
        }
    }

}

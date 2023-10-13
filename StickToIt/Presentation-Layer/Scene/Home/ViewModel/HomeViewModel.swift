//
//  HomeViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 9/26/23.
//

import Foundation
import RxSwift
import RxCocoa

//protocol PlanViewModel {
//    associatedtype UseCase = FetchPlanUseCase<FetchPlanRepository>
//
//    init(
//        planUseCase: UseCase,
//        mainQueue: DispatchQueue
//    )
//
//    func fetchPlan(_ query: PlanQuery)
//    func fetchWeeklyPlan(of week: Int)
//}

final class HomeViewModel<UseCase: FetchPlanUseCase>
where UseCase.Model == Plan, UseCase.Query == PlanQuery
{

    private let useCase: UseCase
    private let mainQueue: DispatchQueue
    
    var userPlanList = BehaviorRelay(value: [PlanQuery]())
    var currentPlan = PublishRelay<Plan>()
    var currentDayPlans = BehaviorRelay(value: [DayPlan]())
    var currentWeek = BehaviorRelay<Int>(value: 1)
    var currentPlanData: Plan?
    
    var daysOfWeek: Set<Week> {
        return currentPlanData?.executionDaysOfWeekday ?? []
    }
    
    private let disposeBag = DisposeBag()
    
    init(
        useCase: UseCase,
        mainQueue: DispatchQueue = .main
    ) {
        self.useCase = useCase
        self.mainQueue = mainQueue
        
    
        // 사용자가 장기간 앱을 사용하지않은경우 날짜가 지난지 어떻게 알것인지.
        // -> 포그라운드 상태에 진입할때 비동기로 몇주가 지났는지 확인?
        // -> 타이머 사용
    }
    
    // MARK: External method
    
    func viewDidLoad() {
        
        fetchAllPlanQueries()
    }
    
    func reload() {
        fetchAllPlanQueries()
    }
    
    func fetchPlan(_ query: PlanQuery) {
        // 쿼리로 현재 플랜에 대한 정보 가져오기
        useCase.fetch(query: query) { plan in
            self.currentPlan.accept(plan)
            self.currentPlanData = plan
        }
    }
    
    func fetchWeeklyPlan(of week: Int) {
        
        
        currentPlan
            .map { $0.dayPlans }
            .map { $0.filter { $0.week == week }}
            .ifEmpty(default: nil)
            .subscribe(onNext: { _dayPlans in
                guard let _dayPlans = _dayPlans else { return }
                self.currentDayPlans.accept(_dayPlans)
            })
            .disposed(by: disposeBag)
    }
    
    func loadImage(dayPlanID: UUID, completion: @escaping (Data?) -> Void) {
        useCase.loadImageFromDocument(fileName: dayPlanID.uuidString) { data in
            print(data)
            completion(data)
        }
    }
    
    
    
    // MARK: internal Method
    
    private func fetchAllPlanQueries() {

        useCase.fetchAll { [weak self] plans in
            let planQueries = plans.map {
                PlanQuery(planID: $0._id,
                          planName: $0.name ?? String())
            }
            
            self?.userPlanList.accept(planQueries)
        }
    }
}

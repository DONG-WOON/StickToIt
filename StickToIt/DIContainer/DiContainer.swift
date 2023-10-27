//
//  DiContainer.swift
//  StickToIt
//
//  Created by 서동운 on 10/27/23.
//

import Foundation

final class DIContainer {
    
    static let shared = DIContainer()
    
    lazy var databaseManager = DatabaseManagerImp()
    
    
    // MARK: UseCases
    
    func makeFetchPlanUseCase() -> some FetchPlanUseCase<PlanQuery, Plan, PlanEntity> {
        FetchPlanUseCaseImp(repository: planRepository)
    }
    
    func makeCreatePlanUseCase() -> some CreatePlanUseCase<Plan> {
        CreatePlanUseCaseImp(repository: planRepository)
    }
    
    func makeDeletePlanUseCase() -> any DeletePlanUseCase {
        DeletePlanUseCaseImp(repository: planRepository)
    }
    
    func makeFetchUserUseCase() -> any FetchUserUseCase {
        FetchUserUseCaseImp(repository: userRepository)
    }
    
    func makeUpdateUserUseCase() -> some UpdateUserUseCase<UserEntity, User, UUID> {
        UpdateUserUseCaseImp(repository: userRepository)
    }
    
    func makeUpdateDayPlanUseCase() -> some UpdateDayPlanUseCase<DayPlan, DayPlanEntity> {
        UpdateDayPlanUseCaseImp(repository: dayPlanRepository)
    }
    
    
    
    // MARK: Repository
    
    lazy var planRepository = makePlanRepository()
    lazy var userRepository = makeUserRepository()
    lazy var dayPlanRepository = makeDayPlanRepository()
    
    
    func makePlanRepository() -> any PlanRepository<PlanQuery, Plan, PlanEntity> {
        PlanRepositoryImp(
            networkService: nil,
            databaseManager: databaseManager
        )
    }
    
    func makeUserRepository() -> any UserRepository<User, UserEntity, UUID> {
        UserRepositoryImp(
            networkService: nil,
            databaseManager: databaseManager
        )
    }
    
    func makeDayPlanRepository() -> any DayPlanRepository<DayPlan, DayPlanEntity>  {
        DayPlanRepositoryImp(
            networkService: nil,
            databaseManager: databaseManager
        )
    }
    
    // MARK: ViewModel
    
    static func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            updateUserUseCase: shared.makeUpdateUserUseCase(),
            fetchUserUseCase: shared.makeFetchUserUseCase(),
            fetchPlanUseCase: shared.makeFetchPlanUseCase(),
            deletePlanUseCase: shared.makeDeletePlanUseCase()
        )
    }
    
    static func makeCreatePlanViewModel() -> CreatePlanViewModel {
        CreatePlanViewModel(
            planUseCase: shared.makeCreatePlanUseCase(),
            userUseCase: shared.makeUpdateUserUseCase()
        )
    }
    
    static func makeDayPlanViewModel(dayPlan: DayPlan) -> DayPlanViewModel {
        DayPlanViewModel(
            dayPlan: dayPlan,
            updateDayPlanUseCase: shared.makeUpdateDayPlanUseCase()
        )
    }
    
    static func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(
            planRepository: PlanRepositoryImp(
                networkService: nil,
                databaseManager: shared.databaseManager
            ),
            userRepository: UserRepositoryImp(
                networkService: nil,
                databaseManager: shared.databaseManager
            )
        )
    }
    
    static func makeUserSettingViewModel() -> UserSettingViewModel {
        UserSettingViewModel(repository: shared.makeUserRepository())
    }
}

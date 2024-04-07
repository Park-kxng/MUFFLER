//
//  GoalMainViewModel.swift
//  Money-Planner
//
//  Created by 유철민 on 2/17/24.
//

import Foundation
import RxSwift
import RxMoya
import RxCocoa
import Moya


class GoalMainViewModel {
    
    static let shared = GoalMainViewModel()

    private let goalRepository = GoalRepository.shared
    private let disposeBag = DisposeBag()
    
    // Observables for goals
    let nowGoalResponse : BehaviorRelay<NowResponse?> = BehaviorRelay(value: nil)
    let nowGoal : BehaviorRelay<Goal_?> = BehaviorRelay(value: nil)
//    let notNowResult = BehaviorRelay<NotNowResult?>(value: nil) // Holds both past and future goals
    let notNowGoals = BehaviorRelay<[Goal_]>(value : [])
    let futureGoals = BehaviorRelay<[Goal_]>(value: [])
    let pastGoals = BehaviorRelay<[Goal_]>(value: [])
    
    var hasNext = false
    private var endDate: String?

    private init() {}

    // Initial fetch without endDate
    func fetchInitialGoals() {
//        resetData()
        fetchNowGoal()
        fetchNotNowGoals(forceRefresh: true)
    }
    
    func fetchNowGoal() {
        goalRepository.getNowGoal()
            .subscribe(onSuccess: { [weak self] nowResponse in
                self?.nowGoalResponse.accept(nowResponse)
                self?.nowGoal.accept(nowResponse.result)
            }, onFailure: { error in
                // Handle error
                print("error : nowResponse")
                print(error)
            })
            .disposed(by: disposeBag)
    }

    
    func fetchNotNowGoals(forceRefresh : Bool = true) {
        
        if forceRefresh {
            endDate = nil
            hasNext = false
            notNowGoals.accept([])
            print("refresh!!")
        }
        
        goalRepository.getNotNowGoals(endDate: endDate)
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                if response.isSuccess {
                    print("\nget Not Now goals Response : ")
                    print(response)
                    let newGoals = response.result.futureGoal + response.result.endedGoal
                    // 새로운 데이터 병합
                    let updatedGoals = notNowGoals.value + newGoals
                    notNowGoals.accept(updatedGoals)
                    // 페이징 정보 업데이트
                    self.hasNext = response.result.hasNext
                    self.endDate = newGoals.last?.endDate
                }
            }, onFailure: { [weak self] error in
                print("Error loading NotNowGoals: \(error)")
            }).disposed(by: disposeBag)
    }

    func fetchNextPageIfPossible(completion: @escaping () -> Void) {
        guard hasNext else {
            print("notNowGoals 추가 없음")
            completion()
            return
        }
        fetchNotNowGoals(forceRefresh: false)
        print("notNowGoals 추가")
        completion()
    }

     //초기화 용도
    func resetData() {
        nowGoal.accept(nil)
        notNowGoals.accept([])
        hasNext = false
        endDate = nil
    }
}

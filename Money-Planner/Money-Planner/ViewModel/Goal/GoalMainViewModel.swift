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

    func fetchNextPageIfPossible(completion: @escaping () -> Void) {//
        guard hasNext else {
            print("notNowGoals 추가 없음")
            completion()
            return
        }
        hasNext = false // 배울점 : 여기서 hasNext를 해두지 않으면, fetchNotNowGoals가 hasNext를 바꾸는 속도보다, GoalMainViewController에서 fetchNextPageIfPossible를 호출하는 속도가 빨라 같은 내용이 여러번 들어오게 된다. 어차피 여기서 hasNext를 false로 바꿔도, fetchNotNowGoals가 올바르게 바꿔준다.
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

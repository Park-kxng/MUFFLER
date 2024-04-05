//
//  GoalEditViewModel.swift
//  Money-Planner
//
//  Created by 유철민 on 3/15/24.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class GoalEditViewModel {
    
    static let shared = GoalEditViewModel()
    let repository = GoalRepository.shared
    let disposeBag = DisposeBag()
    
    var startDate: String?
    var endDate: String?
    var goalBudget : Int64?
    var goalDetailRelay = PublishRelay<GoalDetail>()
    var categoryGoals : [CategoryGoal]? //PublishRelay<>()
    var dailyBudgets : [Int64]?//PublishRelay<>()
    var deleteResponseRelay = PublishRelay<DeleteGoalResponse>()
    
    //goalDetail 호출
    func fetchGoal(goalId: String) {
        repository.getGoalDetail(goalId: goalId)
            .subscribe { [weak self] event in
                switch event {
                case .success(let response):
                    self?.goalDetailRelay.accept(response.result)
                    self?.categoryGoals = response.result.categoryGoals
                    self?.dailyBudgets = response.result.dailyBudgets
                    self?.goalBudget = response.result.totalBudget
                    self?.startDate = response.result.startDate
                    self?.endDate = response.result.endDate
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    ///삭제 함수
    func deleteGoalByGoalID(goalId: Int64) {
        repository.deleteGoal(goalId: String(goalId))
            .subscribe(onSuccess: { [weak self] response in
                // 성공 응답 처리
                self?.deleteResponseRelay.accept(response)
                print("목표 삭제 성공: \(response)")
            }, onFailure: { [weak self] error in
                // 오류 응답 처리
                print("목표 삭제 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func updateGoalTitleAndIcon(goalId: String, newTitle: String, newIcon: String) {
        repository.updateTitleAndIcon(goalId: goalId, title: newTitle, icon: newIcon)
            .subscribe { [weak self] event in
                switch event {
                case .success(let editionResponse):
                    if editionResponse.isSuccess {
                        print("Goal title and icon updated successfully")
                        // Perform further actions if needed, like informing the user or updating the UI
                    } else {
                        print("Failed to update goal title and icon: \(editionResponse.message)")
                    }
                case .failure(let error):
                    print("Error while updating goal title and icon: \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
    }
    
    func updateGoalCategoryGoals(goalId: String, newCategoryGoals: [CategoryGoal]) {
        repository.updateCategoryGoals(goalId: goalId, categoryGoals: newCategoryGoals)
            .subscribe { [weak self] event in
                switch event {
                case .success(let editionResponse):
                    if editionResponse.isSuccess {
                        print("Category goals updated successfully")
                        // Update local data and UI as necessary
                        
                    } else {
                        print("Failed to update category goals: \(editionResponse.message)")
                    }
                case .failure(let error):
                    print("Error while updating category goals: \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
    }
    
    func updateGoalDailyBudgets(goalId: String, newDailyBudgets: [Int64]) {
        repository.updateDailyBudgets(goalId: goalId, dailyBudgets: newDailyBudgets)
            .subscribe { [weak self] event in
                switch event {
                case .success(let editionResponse):
                    if editionResponse.isSuccess {
                        print("Daily budgets updated successfully")
                        // Update local data and UI as necessary
                        
                    } else {
                        print("Failed to update daily budgets: \(editionResponse.message)")
                    }
                case .failure(let error):
                    print("Error while updating daily budgets: \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
    }
    
}

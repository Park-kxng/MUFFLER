//
//  GoalDetailViewModel.swift
//  Money-Planner
//
//  Created by 유철민 on 2/17/24.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class GoalDetailViewModel {
    
    static let shared = GoalDetailViewModel()
    let repository = GoalRepository.shared
    let disposeBag = DisposeBag()
    let goalRelay = PublishRelay<GoalDetail>()
    let goalReportRelay = PublishRelay<GoalReportResult>()
    let dailyExpenseListRelay = BehaviorRelay<[DailyExpense]>(value: [])//PublishRelay<[DailyExpense]>()
    let selectedCategoryRelay = BehaviorRelay<[String : Bool]>(value: [:])
    
    var hasNext = false
    private var lastDate: String?
    private var lastExpenseId: String?
    private var selectedStartDate: String?
    private var selectedEndDate: String?
    
    func updateSelectedCategory(selected : [String : Bool]){
        selectedCategoryRelay.accept(selected)
    }
    
    func fetchGoal(goalId: String) {
        repository.getGoalDetail(goalId: goalId)
            .subscribe { [weak self] event in
                switch event {
                case .success(let response):
                    self?.goalRelay.accept(response.result)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func fetchGoalReport(goalId: String) {
        repository.getGoalReport(goalId: goalId)
            .subscribe { [weak self] event in
                switch event {
                case .success(let response):
                    self?.goalReportRelay.accept(response.result)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func fetchNextPageIfPossible(goalId: String, completion: @escaping () -> Void) {
        guard hasNext else {
            completion()
            return
        }
        fetchBySelectedDates(goalId: goalId, startDate: self.selectedStartDate!, endDate: self.selectedEndDate!, forceRefresh: false, completion: completion)
    }
    
    func fetchBySelectedDates(goalId: String, startDate: String, endDate: String, forceRefresh: Bool = false, completion: @escaping () -> Void) {
        if forceRefresh {
            lastDate = nil
            lastExpenseId = nil
            // Emit an empty list to clear existing data
            hasNext = false
            dailyExpenseListRelay.accept([])
        }
        
        self.selectedStartDate = startDate
        self.selectedEndDate = endDate
        
        repository.getWeeklyExpenses(goalId: goalId, startDate: startDate, endDate: endDate, size: "10", lastDate: lastDate, lastExpenseId: lastExpenseId)
            .subscribe(onSuccess: { [weak self] expenseResponse in
                self?.updatePaginationInfo(from: expenseResponse.result)
                let newExpenses = expenseResponse.result.dailyExpenseList
                // Decide to either clear existing data and emit new or append to existing data
                if forceRefresh {
                    // Directly emit the new data
                    self?.dailyExpenseListRelay.accept(expenseResponse.result.dailyExpenseList)
                } else {
                    // Append new data to existing and emit
                    self?.dailyExpenseListRelay
                        .take(1) // Take the current state before appending
                        .subscribe(onNext: { currentList in
                            let updatedList = self?.mergeExpenseLists(currentList: currentList, with: newExpenses)
                            self?.dailyExpenseListRelay.accept(updatedList ?? [])
                        })
                        .disposed(by: self!.disposeBag)
                }
                completion()
            }, onFailure: { error in
                print("Error fetching expenses: \(error.localizedDescription)")
                completion()
            })
            .disposed(by: disposeBag)
    }
    
    func fetchExpensesUsingGoalDetail(goalId: String, forceRefresh: Bool = false) {
        if forceRefresh {
            lastDate = nil
            lastExpenseId = nil
            // Emit an empty list to clear existing data
            hasNext = false
            dailyExpenseListRelay.accept([])
        }
        
        repository.getGoalDetail(goalId: goalId)
            .flatMap { [weak self] goalDetailResponse -> Single<WeeklyExpenseResponse> in
                guard let self = self else { return .never() }
                let startDate = goalDetailResponse.result.startDate
                let endDate = goalDetailResponse.result.endDate
                self.selectedStartDate = startDate
                self.selectedEndDate = endDate
                return self.repository.getWeeklyExpenses(goalId: goalId, startDate: startDate, endDate: endDate, size: "10", lastDate: self.lastDate, lastExpenseId: self.lastExpenseId)
            }.subscribe(onSuccess: { [weak self] expenseResponse in
                self?.updatePaginationInfo(from: expenseResponse.result)
                let newExpenses = expenseResponse.result.dailyExpenseList
                // Check if it's a force refresh or a subsequent fetch
                if forceRefresh {
                    // For force refresh, directly emit the new list
                    self?.dailyExpenseListRelay.accept(newExpenses)
                } else {
                    // For subsequent fetches, append new data to the existing data
                    self?.dailyExpenseListRelay
                        .take(1) // Take the current value of the relay
                        .subscribe(onNext: { currentList in
                            let updatedList = self?.mergeExpenseLists(currentList: currentList, with: newExpenses)
                            self?.dailyExpenseListRelay.accept(updatedList ?? [])
                            
                        })
                        .disposed(by: self!.disposeBag)
                }
            }, onFailure: { error in
                print("Error fetching expenses: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
    
    private func updatePaginationInfo(from result: WeeklyExpenseResult) {
        if let lastExpenseDay = result.dailyExpenseList.last,
           let lastExpense = lastExpenseDay.expenseDetailList.last {
            self.lastDate = lastExpenseDay.date
            self.lastExpenseId = String(lastExpense.expenseId)
        }
        self.hasNext = result.hasNext
    }
    
    private func mergeExpenseLists(currentList: [DailyExpense], with newList: [DailyExpense]) -> [DailyExpense] {
        var mergedList = currentList
        
        for newExpense in newList {
            if let index = mergedList.firstIndex(where: { $0.date == newExpense.date }) {
                // 날짜가 동일한 경우 세부 내역을 합칩니다.
                let updatedExpenseDetailList = mergedList[index].expenseDetailList + newExpense.expenseDetailList
                let updatedTotalCost = updatedExpenseDetailList.reduce(0) { $0 + $1.cost }
                let updatedDailyExpense = DailyExpense(date: newExpense.date, dailyTotalCost: Int64(updatedTotalCost), expenseDetailList: updatedExpenseDetailList)
                mergedList[index] = updatedDailyExpense
            } else {
                // 날짜가 다른 경우 새 항목을 추가합니다.
                mergedList.append(newExpense)
            }
        }
        
        return mergedList
    }
    
}

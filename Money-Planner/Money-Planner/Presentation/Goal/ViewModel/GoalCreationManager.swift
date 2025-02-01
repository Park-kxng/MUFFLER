//
//  GoalCreationManager.swift
//  Money-Planner
//
//  Created by 유철민 on 2/15/24.
//

import Foundation
import RxSwift
import RxCocoa

// GoalCreationManager
class GoalCreationManager {
    
    static let shared = GoalCreationManager()

    var icon: String?
    var goalTitle: String?
    var goalDetail: String? // Added detail property
    var goalBudget: Int64? = 1000
    var startDate: String? = "2024-3-12"
    var endDate: String? = "2024-4-27"
    var categoryGoals: [CategoryGoal] = []
    var dailyBudgets: [Int64] = [] // Added dailyBudgets property
    var canRestore : Bool?
    var restore : Bool?
    
    private let disposeBag = DisposeBag()
    let postGoalResultRelay = PublishRelay<Bool>()

    private init() {} // Private initializer to ensure singleton usage

    func addCategoryGoals(categoryGoals: [CategoryGoal]) {
        var isUnique = true
        let existingCategoryIds = self.categoryGoals.map { $0.categoryId }
        
        for categoryGoal in categoryGoals {
            if existingCategoryIds.contains(categoryGoal.categoryId) {
                isUnique = false
                break
            }
        }
        
        if isUnique {
            self.categoryGoals.append(contentsOf: categoryGoals)
            print("Category goals added successfully.")
        } else {
            print("One or more category goals have duplicate category IDs.")
        }
    }
    
    //일별 목표를 등록
    func addDailyBudgets(budgets: [Int64]) {
        
        guard let startDateString = startDate, let endDateString = endDate,
              let startDate = startDate?.toDate, let endDate = endDate?.toDate else {
            print("Invalid dates")
            return
        }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day], from: startDate, to: endDate)
        
        guard let days = dateComponents.day else {
            print("Could not calculate the number of days")
            return
        }
        
        // endDate를 포함하기 위해 +1
        if days + 1 == budgets.count {
            self.dailyBudgets = budgets
        } else {
            print("The number of budgets does not match the number of days")
        }
    }
    
    func restoration(canRestore : Bool, restore : Bool?){
        self.canRestore = canRestore
        self.restore = restore
    }

    func clear() {
        icon = nil
        goalTitle = nil
        goalDetail = nil // Clear the detail
        goalBudget = nil
        startDate = nil
        endDate = nil
//        categoryGoals = [] // Clear categoryGoals
        dailyBudgets = [] // Clear dailyBudgets
        restore = nil
        canRestore = nil
    }
    
    func postContent(){
        print("마지막 체크")
        print(icon)
        print(goalTitle)
        print(startDate)
        print(endDate)
        print(goalBudget)
        print(categoryGoals)
        print(dailyBudgets)
        print(canRestore)
        print(restore)
        GoalRepository.shared.postContent(icon: icon!, title: goalTitle!, startDate: startDate!, endDate: endDate!, totalBudget: goalBudget!, categoryGoals: categoryGoals, dailyBudgets: dailyBudgets, canRestore: canRestore!, restore: restore!){
            _ in
        }
        clear()
    }
    
}

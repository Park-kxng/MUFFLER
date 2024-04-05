//
//  GoalPeriodViewModel.swift
//  Money-Planner
//
//  Created by 유철민 on 2/17/24.
//

import Foundation
import RxSwift
import RxCocoa

class GoalPeriodViewModel {
    
    static let shared = GoalPeriodViewModel()
    private let goalRepository = GoalRepository.shared
    private let disposeBag = DisposeBag()
    
    // RxSwift Relay to hold and emit changes in the periods of previous goals
    let previousGoalTerms = BehaviorRelay<[Term]>(value: [])
    let canRestore = BehaviorRelay<Bool>(value: false)
    
    // Initializer
    init() {
        fetchPreviousGoals()
    }
    
    private func fetchPreviousGoals() {
        goalRepository.getPreviousGoals()
            .subscribe(onSuccess: { [weak self] response in
                if response.isSuccess {
                    // Update the Relay with the new terms
                    self?.previousGoalTerms.accept(response.result.terms)
                } else {
                    // Handle the error or failed case, e.g., show an error message.
                    print("Failed to fetch previous goals: \(response.message)")
                }
            }, onFailure: { error in
                // Handle any errors that occurred during the network request.
                print("Error fetching previous goals: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func fetchCanRestore(startDate: String, endDate: String){
        goalRepository.getCanRestore(startDate: startDate, endDate: endDate)
            .subscribe(onSuccess: { [weak self] response in
                self?.canRestore.accept(response)
            }, onFailure: { error in
                // Handle any errors that occurred during the network request.
                print("Error fetching being able to restore : \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
}

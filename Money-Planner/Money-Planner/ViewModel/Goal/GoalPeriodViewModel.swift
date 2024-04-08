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
    var canRestore = false
    
    // Initializer
    init() {
        fetchPreviousGoals()
    }
    
    func fetchPreviousGoals() {
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
    
    func fetchCanRestore(startDate: String, endDate: String, completion: @escaping (Bool) -> Void){
        goalRepository.getCanRestore(startDate: startDate, endDate: endDate)
            .subscribe(onSuccess: { [weak self] response in
                self?.canRestore = response
                print("canRestore 여부 : \(response)")
                completion(self!.canRestore)
            }, onFailure: { error in
                // Handle any errors that occurred during the network request.
                print("Error fetching being able to restore : \(error.localizedDescription)")
                completion(self.canRestore)
            })
            .disposed(by: disposeBag)
    }
    
}

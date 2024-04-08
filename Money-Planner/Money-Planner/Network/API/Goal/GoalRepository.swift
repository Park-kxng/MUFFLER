//
//  GoalRepository.swift
//  Money-Planner
//
//  Created by 유철민 on 1/30/24.
//

import Foundation
import RxSwift
import Moya

enum NetworkError: Error {
    case nilResponse
    case decodingError
    // 기타 네트워크 관련 에러
}


final class GoalRepository {
    
    static let shared = GoalRepository()
    private let provider = MoyaProvider<GoalAPI>()
    
    private init() {}
    
    // 현재 진행 중인 목표를 가져오는 메서드
    func getNowGoal() -> Single<NowResponse> {
        return provider.rx.request(.now)
            .filterSuccessfulStatusAndRedirectCodes()
            .map(NowResponse.self)
    }
    
    // 과거 및 미래의 목표들을 가져오는 메서드
    func getNotNowGoals(endDate: String? = nil) -> Single<NotNowResponse> {
        return provider.rx.request(.notNow(endDate: endDate))
            .filterSuccessfulStatusCodes()
            .map(NotNowResponse.self)
    }
    
    
    func getGoalDetail(goalId: String) -> Single<GoalDetailResponse> {
        return provider.rx.request(.getGoalDetail(goalId: goalId))
            .filterSuccessfulStatusCodes()
            .map(GoalDetailResponse.self)
    }
    
    
    // 목표를 생성하는 메서드
    //    func postGoal(request: PostGoalRequest) -> Single<PostGoalResponse> {
    //        return provider.rx.request(.postGoal(request: request))
    //            .filterSuccessfulStatusCodes()
    //            .map(PostGoalResponse.self)
    //    }
    
    // 목표를 삭제하는 메서드
    func deleteGoal(goalId: String) -> Single<DeleteGoalResponse> {
        return provider.rx.request(.deleteGoal(goalId: goalId))
            .filterSuccessfulStatusCodes()
            .map(DeleteGoalResponse.self)
    }
    
    // 이미 만든 목표들의 기간 전부 불러오기
    func getPreviousGoals() -> Single<PreviousGoalResponse> {
        return provider.rx.request(.getPreviousGoals)
            .filterSuccessfulStatusCodes()
            .map(PreviousGoalResponse.self)
    }
    
    func getGoalReport(goalId: String) -> Single<GoalReportResponse> {
        return provider.rx.request(.getGoalReport(goalId: goalId))
            .filterSuccessfulStatusCodes()
            .map(GoalReportResponse.self)
    }
    
    func getWeeklyExpenses(goalId: String, startDate: String, endDate: String, size: String, lastDate: String? = nil, lastExpenseId: String? = nil) -> Single<WeeklyExpenseResponse> {
        return provider.rx.request(.getWeeklyExpenses(goalId: goalId, startDate: startDate, endDate: endDate, size: size, lastDate: lastDate, lastExpenseId: lastExpenseId))
            .filterSuccessfulStatusCodes()
            .map(WeeklyExpenseResponse.self)
    }
    
    //    func postContent( icon: String, title: String, startDate : String, endDate : String, totalBudget : Int64, categoryGoals : [CategoryGoal], dailyBudgets: [Int64], completion: @escaping (Result<Goal?, BaseError>) -> Void){
    //
    //        let request = PostGoalRequest(icon: icon, title: title, startDate: startDate, endDate: endDate, totalBudget: totalBudget, categoryGoals: categoryGoals, dailyBudgets: dailyBudgets)
    //
    //        provider.request(.postContent(request: request)) { result in
    //            switch result {
    //            case let .success(response):
    //                do {
    //                    let response = try response.map(BaseResponse<Goal>.self)
    //                    print(response)
    //                    if(response.isSuccess!){
    //                        completion(.success(response.result))
    //                    }else{
    //                        completion(.failure(.failure(message: response.message!)))
    //                    }
    //
    //                } catch {
    //                    // 디코딩 오류 처리
    //                    print("Decoding error: \(error)")
    //                }
    //            case let .failure(error):
    //                // 네트워크 요청 실패 처리
    //                print("Network request failed: \(error)")
    //                completion(.failure(.networkFail(error: error)))
    //            }
    //        }
    //    }
    
    
    func postContent(icon: String, title: String, startDate: String, endDate: String, totalBudget: Int64, categoryGoals: [CategoryGoal], dailyBudgets: [Int64], canRestore: Bool, restore: Bool, completion: @escaping (Result<Goal?, BaseError>) -> Void) {
        
        let request = PostGoalRequest(icon: icon, title: title, startDate: startDate, endDate: endDate, totalBudget: totalBudget, categoryGoals: categoryGoals, dailyBudgets: dailyBudgets, canRestore: canRestore, restore: restore)
        
        provider.request(.postContent(request: request)) { result in
            switch result {
            case let .success(response):
                do {
                    let response = try response.map(BaseResponse<Goal>.self)
                    print(response)
                    if (response.isSuccess!) {
                        completion(.success(response.result))
                    } else {
                        completion(.failure(.failure(message: response.message!)))
                    }
                    
                } catch {
                    // Decoding error handling
                    print("Decoding error: \(error)")
                }
            case let .failure(error):
                // Network request failure handling
                print("Network request failed: \(error)")
                completion(.failure(.networkFail(error: error)))
            }
        }
    }
    
    func getCanRestore(startDate: String, endDate: String) -> Single<Bool> {
        return provider.rx.request(.restoreGoals(startDate: startDate, endDate: endDate))
            .filterSuccessfulStatusCodes()
            .map { response in
                // Assuming that a status code 200 means canRestore is true
                return response.statusCode == 200
            }
            .catchError { error -> Single<Bool> in
                print("Network request failed: \(error)")
                // Handle error and return an appropriate error
                return .error(NetworkError.nilResponse) // or a more appropriate error from your NetworkError enum
            }
    }
    
    // Function to update the title and icon of a goal
    func updateTitleAndIcon(goalId: String, title: String, icon: String) -> Single<GoalEditionResponse> {
        let request = UpdateGoalRequest(title: title, icon: icon)
        return provider.rx.request(.editTitleAndIcon(goalId: goalId, request: request))
            .filterSuccessfulStatusCodes()
            .map(GoalEditionResponse.self)
            .catchError { error in
                return .error(self.handleError(error))
            }
    }
    
    // Function to update daily budgets for a goal
    func updateDailyBudgets(goalId: String, dailyBudgets: [Int64]) -> Single<GoalEditionResponse> {
        let request = UpdateDailyBudgetsRequest(dailyBudgets: dailyBudgets)
        return provider.rx.request(.editDailyGoal(goalId: goalId, request: request))
            .filterSuccessfulStatusCodes()
            .map(GoalEditionResponse.self)
            .catchError { error in
                return .error(self.handleError(error))
            }
    }
    
    // Function to update category goals for a goal
    func updateCategoryGoals(goalId: String, categoryGoals: [CategoryGoal]) -> Single<GoalEditionResponse> {
        let request = UpdateCategoryGoalsRequest(categoryGoals: categoryGoals)
        return provider.rx.request(.editCategoryGoal(goalId: goalId, request: request))
            .filterSuccessfulStatusCodes()
            .map(GoalEditionResponse.self)
            .catchError { error in
                return .error(self.handleError(error))
            }
    }
    
    // Handle network error
    private func handleError(_ error: Error) -> NetworkError {
        // You can add more error handling logic here based on the type of error
        print("Network request failed: \(error.localizedDescription)")
        return .nilResponse // or a more appropriate error from your NetworkError enum
    }
    
}



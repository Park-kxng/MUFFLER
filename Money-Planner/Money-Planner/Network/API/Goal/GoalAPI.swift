//
//  GoalAPI.swift
//  Money-Planner
//
//  Created by 유철민 on 1/26/24.
//

import Foundation
import RxMoya
import Moya
import RxSwift

enum GoalAPI : TargetType {
    
    case deleteGoal(goalId: String)
    case getGoalDetail(goalId: String)
    
    //가능
    case now
    case notNow(endDate: String?)
    case getGoalReport(goalId: String)
    case getWeeklyExpenses(goalId: String, startDate: String, endDate: String, size: String, lastDate: String?, lastExpenseId: String?)
    
    //시험
    case getPreviousGoals
    case postContent(request: PostGoalRequest)
    
    case restoreGoals(startDate: String, endDate: String)
    
    //편집
    case editTitleAndIcon(goalId: String, request: UpdateGoalRequest)
    case editDailyGoal(goalId: String, request: UpdateDailyBudgetsRequest)
    case editCategoryGoal(goalId: String, request: UpdateCategoryGoalsRequest)

}

extension GoalAPI : BaseAPI {
    
    var headers: [String: String]? {
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "accessToken") {
            print("토큰 불러오기 성공")
            print(token)
            return ["Authorization": "Bearer \(token)"]
        } else {
            return nil
        }
    }
    
    var path: String {
        switch self {
//        case .postGoal(let request):
//            return "/api/goal"
        case .deleteGoal(let goalId):
            return "/api/goal/\(goalId)"
        case .getGoalDetail(let goalId):
            return "/api/goal/\(goalId)"
        case .getGoalReport(let goalId):
            return "/api/goal/report/\(goalId)" // 새로운 경로 추가
        case .getWeeklyExpenses:
            return "/api/expense/weekly"
        case .now:
            return "/api/goal/now"
        case .notNow:
            return "/api/goal/not-now"
        case .getPreviousGoals:
            return "/api/goal/previous"
        case .postContent :
            return "/api/goal"
        case .restoreGoals:
            return "/api/goal/restore"
        case .editTitleAndIcon(let goalId, _):
            return "/api/goal/\(goalId)"
        case .editDailyGoal(let goalId, _):
            return "/api/goal/\(goalId)/daily-budgets"
        case .editCategoryGoal(let goalId, _):
            return "/api/goal/\(goalId)/category-goal"
        }
    }
    
    var method: Moya.Method {
        switch self{
        case .now:
            return .get
//        case .postGoal:
//            return .post
        case .getGoalDetail:
            return .get
        case .getWeeklyExpenses:
            return .get
        case .deleteGoal:
            return .delete
        case .postContent:
            return .post
        case .getGoalReport:
            return .get
        case .editDailyGoal, .editCategoryGoal, .editTitleAndIcon:
            return .patch
        default :
            return .get
        }
    }
    
    var task: Task {
        switch self {
//        case .postGoal(let request):
//            return .requestJSONEncodable(request)
        case .getGoalReport: // getGoalReport 추가
            return .requestPlain
        case .now:
            return .requestPlain
        case .notNow(let endDate):
            var parameters: [String: Any] = [:]
            if let endDate = endDate {
                parameters["endDate"] = endDate
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getGoalDetail:
            return .requestPlain
        case .getWeeklyExpenses(let goalId, let startDate, let endDate, let size, let lastDate, let lastExpenseId):
            var parameters: [String: Any] = ["goalId": goalId, "startDate": startDate, "endDate": endDate, "size": size]
            if let lastDate = lastDate {
                parameters["lastDate"] = lastDate
            }
            if let lastExpenseId = lastExpenseId {
                parameters["lastExpenseId"] = lastExpenseId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .deleteGoal:
            return .requestPlain
            
        case .postContent(let request):
            return .requestJSONEncodable(request)
        case .restoreGoals(let startDate, let endDate):
            let parameters = ["startDate": startDate, "endDate": endDate]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .editTitleAndIcon(_, let request):
            return .requestJSONEncodable(request)
        case .editDailyGoal(_, let request):
            return .requestJSONEncodable(request)
        case .editCategoryGoal(_, let request):
            return .requestJSONEncodable(request)
        default:
            return .requestPlain
        }
    }
    
    var sampleData: Data { return Data() }
}

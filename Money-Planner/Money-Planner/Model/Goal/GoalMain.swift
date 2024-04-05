//
//  now.swift
//  Money-Planner
//
//  Created by 유철민 on 2/15/24.
//

import Foundation

//now, 이용주소 : /api/goal/now
struct NowResponse : Codable {
    let isSuccess: Bool
    let message: String
    let result: Goal_

    enum CodingKeys: String, CodingKey {
        case isSuccess
        case message
        case result
    }
    
}

//struct GoalResult: Codable {
//    let goalId: Int64
//    let goalTitle: String
//    let icon: String
//    let totalBudget: Int64
//    let totalCost: Int64
//    let endDate: String
//
//    enum CodingKeys: String, CodingKey {
//        case goalId = "goalId"
//        case goalTitle = "goalTitle"
//        case icon = "icon"
//        case totalBudget = "totalBudget"
//        case totalCost = "totalCost"
//        case endDate = "endDate"
//    }
//}

//not-now,이용주소 : /api/goal/not-now
struct NotNowResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: NotNowResult
}

struct NotNowResult: Codable {
    let futureGoal, endedGoal: [Goal_]
    let hasNext: Bool
}

struct Goal_: Codable {
    let goalId: Int
    let goalTitle: String
    let icon: String
    let totalBudget: Int64
    let totalCost: Int64?
    let endDate: String
    
    enum CodingKeys: String, CodingKey {
        case goalId = "goalId"
        case goalTitle, icon, totalBudget, totalCost, endDate
    }
}


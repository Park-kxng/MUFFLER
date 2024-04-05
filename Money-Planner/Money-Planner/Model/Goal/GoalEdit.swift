//
//  GoalEdit.swift
//  Money-Planner
//
//  Created by 유철민 on 3/15/24.
//

import Foundation

struct GoalDeletionResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: EmptyResult // 이 경우, 'result'는 비어 있는 것으로 가정합니다. 실제 사용 시 필요에 따라 조정할 수 있습니다.

    // 'result' 필드가 비어 있는 경우를 대비한 구조체
    struct EmptyResult: Codable {}
}

struct GoalEditionResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: EmptyResult // 이 경우, 'result'는 비어 있는 것으로 가정합니다. 실제 사용 시 필요에 따라 조정할 수 있습니다.

    // 'result' 필드가 비어 있는 경우를 대비한 구조체
    struct EmptyResult: Codable {}
}

struct UpdateGoalRequest: Encodable {
    let title: String
    let icon: String
}

struct UpdateDailyBudgetsRequest: Encodable {
    let dailyBudgets: [Int64]
}

// Struct to represent the request body for updating category goals
struct UpdateCategoryGoalsRequest: Encodable {
    let categoryGoals: [CategoryGoal]
}

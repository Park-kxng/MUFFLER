//
//  GoalDetail.swift
//  Money-Planner
//
//  Created by 유철민 on 2/16/24.
//

import Foundation

struct GoalDetailResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: GoalDetail
}

//struct GoalDetail: Decodable {
//    let title: String
//    let icon: String
//    let startDate: String
//    let endDate: String
//    let totalBudget: Int64
//    let totalCost: Int64
//}

struct GoalDetail: Decodable {
    let title: String
    let icon: String
    let startDate: String
    let endDate: String
    let totalBudget: Int64
    let totalCost: Int64
    let categoryGoals: [CategoryGoal]
    let dailyBudgets: [Int64]
}

struct GoalReportResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: GoalReportResult
}

struct GoalReportResult: Decodable {
    let zeroDayCount: Int64
    let categoryTotalCosts: [CategoryTotalCost]
    let categoryGoalReports: [CategoryGoalReport]
}

struct CategoryTotalCost: Decodable {
    let categoryName: String
    let totalCost: Int64
}

struct CategoryGoalReport: Decodable {
    let categoryName: String
    let categoryIcon: String
    let categoryBudget: Int64
    let totalCost: Int64
    let avgCost: Int64
    let maxCost: Int64
    let expenseCount: Int64
}

//expense
//struct ExpenseDetail: Decodable {
//    let expenseId: Int64
//    let title: String
//    let cost: Int64
//    let categoryIcon: String
//}

// DailyExpenseList 항목에 대한 구조체
struct DailyExpense: Decodable {
    let date: String
    let dailyTotalCost: Int64
    let expenseDetailList: [ConsumeDetail]
}

// 전체 응답에 대한 구조체
struct WeeklyExpenseResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: WeeklyExpenseResult
}

struct WeeklyExpenseResult: Decodable {
    let dailyExpenseList: [DailyExpense]
    let hasNext: Bool
}

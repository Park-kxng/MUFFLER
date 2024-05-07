//
//  Notification.swift
//  Money-Planner
//
//  Created by Jini on 5/7/24.
//

import Foundation

//알람 동의 불러오기
// MARK: - NotificationGetModel
struct NotificationGetModel: Codable {
    let isDailyPlanRemindAgree, isTodayEnrollRemindAgree, isYesterdayEnrollRemindAgree, isGoalEndReportRemindAgree: Bool
}

//알람 동의 수정
// MARK: - NotificationEditModel
struct NotificationEditModel: Codable {
    let dailyPlanRemindAgree, todayEnrollRemindAgree, yesterdayEnrollRemindAgree, goalEndRemindAgree: Bool
}

//알람 토큰 patch
// MARK: - NotificationToken
struct NotificationToken: Codable {
    let token: String
}

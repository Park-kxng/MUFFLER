//
//  LeaveRequest.swift
//  Money-Planner
//
//  Created by p_kxn_g on 6/21/24.
//

import Foundation

//api/leave
// 로그인
struct LeaveRequest: Codable {
    let socialType: SocialType
    let reason: String
    let authenticationCode: String?

}


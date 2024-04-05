//
//  JoinResponse.swift
//  Money-Planner
//
//  Created by p_kxn_g on 4/4/24.
//

import Foundation

// api/member/join
// 프로필 설정 응답

struct JoinResponse: Decodable {
    let isSuccess: Bool?
    let message: String?
    let result: JoinRequest?
}

//
//  LoginResponse.swift
//  Money-Planner
//
//  Created by p_kxn_g on 4/1/24.
//

import Foundation

// member/login
// 로그인 시 응답
struct LoginResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: LoginResult?

    struct LoginResult: Codable {
        let tokenInfo: TokenInfo?
        let newMember: Bool?
    }

    struct TokenInfo: Codable {
        let type: String
        let accessToken: String
        let refreshToken: String
    }
}


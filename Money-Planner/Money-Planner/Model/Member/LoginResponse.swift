//
//  LoginResponse.swift
//  Money-Planner
//
//  Created by p_kxn_g on 4/1/24.
//

import Foundation
// member/login
// 로그인 시 응답
struct LoginResponse: Decodable {
    let isSuccess: Bool?
    let message: String?
    let result: LoginResult?

   
    struct LoginResult : Decodable {
        let tokenInfo: TokenInfo
        let newMember: Bool
        
    }
    struct TokenInfo : Decodable{
        let type : String
        let accessToken : String
        let refreshToken : String

    }
   
    
}

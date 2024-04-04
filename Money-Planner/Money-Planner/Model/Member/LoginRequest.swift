//
//  LoginRequest.swift
//  Money-Planner
//
//  Created by p_kxn_g on 4/1/24.
//

import Foundation

//api/login
// 로그인
struct LoginRequest: Codable {
    let socialType: SocialType
    let idToken: String
   
    enum SocialType: String, Codable {
        case kakao = "KAKAO"
        case apple = "APPLE"
      
    }
}



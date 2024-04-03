//
//  TokenManager.swift
//  Money-Planner
//
//  Created by p_kxn_g on 4/3/24.
//

import Foundation
import KeychainAccess

// 토큰 관리 - KeyChain
class TokenManager {
    static let shared = TokenManager()
    private let keychain = Keychain(service: "com.umc.Money-Planner")

    var accessToken: String? {
        get { try? keychain.get("accessToken") }
        set { try? keychain.set(newValue ?? "", key: "accessToken") }
    }

    var refreshToken: String? {
        get { try? keychain.get("refreshToken") }
        set { try? keychain.set(newValue ?? "", key: "refreshToken") }
    }
    func isLoggedIn() -> Bool {
           return accessToken != nil
    }
    
    // 로그인 성공 후 받은 토큰 저장
    func handleLoginSuccess(accessToken: String, refreshToken: String) {
        TokenManager.shared.accessToken = accessToken
        TokenManager.shared.refreshToken = refreshToken
    }

    // 토큰 삭제
    func clearTokens() {
        do {
                try keychain.remove("accessToken")
                try keychain.remove("refreshToken")
            
            } catch let error {
                print("토큰 삭제 중 오류 발생: \(error)")
            }
    }
    
    
}

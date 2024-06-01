//
//  AuthService.swift
//  Money-Planner
//
//  Created by p_kxn_g on 5/23/24.
//

import Foundation
import RxSwift

class AuthService {
    static let shared = AuthService()
    
    private let tokenManager = TokenManager.shared
    private var isRefreshing = false
    private var onRefreshCallbacks: [(Bool) -> Void] = []
    private let disposeBag = DisposeBag()
    
    private init() {}
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
        guard !isRefreshing else {
            onRefreshCallbacks.append(completion)
            return
        }
        
        guard let refreshToken = tokenManager.refreshToken else {
            completion(false)
            return
        }
        
        isRefreshing = true
        onRefreshCallbacks.append(completion)
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        LoginRepository().refreshToken(refreshToken: request)
            .subscribe(onNext: { response in
                self.tokenManager.handleLoginSuccess(accessToken: response.result?.accessToken ?? "", refreshToken: response.result?.refreshToken ?? "")
                self.isRefreshing = false
                self.onRefreshCallbacks.forEach { $0(true) }
                self.onRefreshCallbacks.removeAll()
            }, onError: { error in
                self.isRefreshing = false
                self.onRefreshCallbacks.forEach { $0(false) }
                self.onRefreshCallbacks.removeAll()
                self.tokenManager.clearTokens()
            })
            .disposed(by: disposeBag)
    }
}


//
//  TokenAuthPlugin.swift
//  Money-Planner
//
//  Created by p_kxn_g on 4/5/24.
//

import Foundation
import Moya
import UIKit

final class TokenAuthPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let authTarget = target as? AuthenticatedAPI, authTarget.requiresAuthentication else {
            print("인증이 필요하지 않는 요청")
            return request
        }

        guard let accessToken = TokenManager.shared.accessToken else {
            print("엑세스 토큰을 가져올 수 없음")
            return request
        }

        var request = request
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        print("헤더에 엑세스 토큰 추가 - 토큰 \(accessToken)")
        return request
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            handleResponse(response, target: target)
        case .failure(let error):
            if let response = error.response {
                handleResponse(response, target: target)
            } else {
                print("결과 : 실패 - api 연결")
            }
        }
    }

    private func handleResponse(_ response: Response, target: TargetType) {
        print("response.statuscode -\(response.statusCode)")
        if response.statusCode == 401 {
            refreshToken()
        }
    }

    private func refreshToken() {
        print("401 - 엑세스 토큰 갱신 필요")
        DispatchQueue.main.async {
            let viewModel = LoginViewModel()
            viewModel.refreshAccessTokenIfNeeded()
        }
    }
}

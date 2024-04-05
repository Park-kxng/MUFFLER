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
            guard let authTarget = target as? AuthenticatedAPI, authTarget.requiresAuthentication,
                  let accessToken = TokenManager.shared.accessToken else {
                return request
            }

            var request = request
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            return request
        }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            print("결과 : api 연결 성공 - \(response)")
            break
        case .failure(let error):
            print(error)
            if let response = error.response {
                // HTTP 상태 코드를 확인
                if response.statusCode == 401 {
                    print("엑세스 토큰 갱신 필요")
                    DispatchQueue.main.async {
                        let viewModel = LoginViewModel()
                         viewModel.refreshAccessTokenIfNeeded()
                    }

                }
            } else {
                // 오류가 발생했지만, response 객체가 없는 경우 (예: 네트워크 연결 오류)
                // 알림 띄우기
                print("결과 : 실패 - api 연결")
                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let topViewController = windowScene.windows.first?.rootViewController {
                        let alertController = UIAlertController(title: "네트워크 연결 오류", message: "네트워크 연결을 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        topViewController.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }

}

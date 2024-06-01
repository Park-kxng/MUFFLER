import Moya
import RxSwift
import Foundation

final class TokenAuthPlugin: PluginType {
    private let tokenManager = TokenManager.shared
    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [(TargetType, (Result<Moya.Response, MoyaError>) -> Void)] = []

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        if let accessToken = tokenManager.accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            print("[TokenAuthPlugin] Added access token to request: \(accessToken)")
        } else {
            print("[TokenAuthPlugin] No access token available")
        }
        return request
    }

    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        print("[TokenAuthPlugin] didReceive called with result: \(result)")

        switch result {
        case .success(let response):
            if response.statusCode == 401 {
                print("[TokenAuthPlugin] Received 401 error, need to refresh token")
                handleTokenRefresh(target: target, error: .statusCode(response))
            } else {
                print("[TokenAuthPlugin] Request succeeded with status code: \(response.statusCode)")
            }
        case .failure(let error):
            if let response = error.response, response.statusCode == 401 {
                print("[TokenAuthPlugin] Received 401 error, need to refresh token")
                handleTokenRefresh(target: target, error: error)
            } else {
                print("[TokenAuthPlugin] Request failed with error: \(error)")
            }
        }
    }

    private func handleTokenRefresh(target: TargetType, error: MoyaError) {
        print("[TokenAuthPlugin - 토큰 갱신")
        lock.lock()
        defer { lock.unlock() }
        
        requestsToRetry.append((target, { result in
            // 재요청 로직
            let provider = MoyaProvider<MultiTarget>(plugins: [TokenAuthPlugin()])
            provider.request(MultiTarget(target)) { result in
                print("[TokenAuthPlugin] Retrying original request")
            }
        }))

        if !isRefreshing {
            isRefreshing = true
            print("[TokenAuthPlugin] Refreshing token...")

            // LoginViewModel 인스턴스를 통해 refreshAccessTokenIfNeeded 호출
            let loginViewModel = LoginViewModel()
            loginViewModel.refreshAccessTokenIfNeeded()
                .subscribe(onNext: { [weak self] success in
                    guard let self = self else { return }
                    self.lock.lock()
                    defer { self.lock.unlock() }
                    
                    self.isRefreshing = false
                    if success {
                        print("[TokenAuthPlugin] Token refreshed successfully")
                    } else {
                        print("[TokenAuthPlugin] Failed to refresh token")
                    }
                    self.requestsToRetry.forEach { target, completion in
                        if success {
                            let provider = MoyaProvider<MultiTarget>(plugins: [TokenAuthPlugin()])
                            provider.request(MultiTarget(target)) { result in
                                print("[TokenAuthPlugin] Retrying original request")
                                completion(result)
                            }
                        } else {
                            completion(.failure(error))
                        }
                    }
                    self.requestsToRetry.removeAll()
                }, onError: { error in
                    self.isRefreshing = false
                    print("[TokenAuthPlugin] Error refreshing token: \(error)")
                    self.requestsToRetry.forEach { _, completion in
                        completion(.failure(error as! MoyaError))
                    }
                    self.requestsToRetry.removeAll()
                })
                .disposed(by: DisposeBag())
        } else {
            print("[TokenAuthPlugin] Token is already being refreshed, appending request to queue")
        }
    }
}


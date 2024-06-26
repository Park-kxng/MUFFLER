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

        if let url = request.url {
            print("[TokenAuthPlugin] Preparing request for URL: \(url.absoluteString)")
        }

        return request
    }

    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        print("[TokenAuthPlugin] didReceive called with result: \(result)")

        switch result {
        case .success(let response):
            print("[TokenAuthPlugin] Request succeeded with status code: \(response.statusCode)")
            if response.statusCode == 401 {
                print("[TokenAuthPlugin] Received 401 error, need to refresh token")
                handleTokenRefresh(target: target, error: .statusCode(response))
            }
        case .failure(let error):
            print("[TokenAuthPlugin] Request failed with error: \(error)")
            if let response = error.response, response.statusCode == 401 {
                print("[TokenAuthPlugin] Received 401 error, need to refresh token")
                handleTokenRefresh(target: target, error: error)
            } else if case .underlying(let nsError as NSError, _) = error, nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
                print("[TokenAuthPlugin] Request was explicitly cancelled")
            } else {
                print("[TokenAuthPlugin] Other error occurred: \(error)")
            }
        }
    }

    private func handleTokenRefresh(target: TargetType, error: MoyaError) {
        print("[TokenAuthPlugin] Token refresh attempt underway")
        lock.lock()
        defer { lock.unlock() }

        requestsToRetry.append((target, { result in
            let provider = MoyaProvider<MultiTarget>(plugins: [TokenAuthPlugin()])
            provider.request(MultiTarget(target)) { result in
                print("[TokenAuthPlugin] Retrying original request")
            }
        }))

        if !isRefreshing {
            isRefreshing = true
            print("[TokenAuthPlugin] Refreshing token...")

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

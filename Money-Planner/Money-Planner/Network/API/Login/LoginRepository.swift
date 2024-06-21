//
//  LoginRepository.swift
//  Money-Planner
//
//  Created by p_kxn_g on 3/7/24.
//

import Foundation
import RxSwift
import RxMoya
import Moya

class LoginRepository {
    private let provider = MoyaProvider<LoginAPI>(plugins: [TokenAuthPlugin()]).rx
    let disposeBag = DisposeBag()
    
    // member controller
    
    func connect() -> Observable<ConnectModel> {
        return provider.request(.connect)
            .map(ConnectModel.self)
            .asObservable()
            .catch { error -> Observable<ConnectModel> in
                        // 여기서 네트워크 오류를 처리하고, 필요한 경우 사용자에게 알림
                        print("Network request failed: \(error.localizedDescription)")
                        throw error // 또는 사용자 정의 오류를 Observable로 반환
                    }
    }
    // 엑세스 토큰 갱신
    func refreshToken(refreshToken: RefreshTokenRequest) -> Observable<RefreshTokenResponse> {
            return provider.request(.refreshToken(refreshToken: refreshToken))
                .map { response in
                    do {
                        let decodedResponse = try JSONDecoder().decode(RefreshTokenResponse.self, from: response.data)
                        print("log: 토큰 갱신 응답 수신, 응답: \(decodedResponse)")
                        return decodedResponse
                    } catch {
                        print("log: 디코딩 오류, 에러: \(error), 응답 데이터: \(String(data: response.data, encoding: .utf8) ?? "nil")")
                        throw error
                    }
                }
                .asObservable()
        }

    
    func login(request : LoginRequest)-> Observable<LoginResponse> {
        return provider.request(.login(request: request))
            .map(LoginResponse.self)
            .asObservable()
    }
    func join(request : JoinRequest)-> Observable<JoinResponse> {
        return provider.request(.join(request: request))
            .map(JoinResponse.self)
            .asObservable()
    }

}



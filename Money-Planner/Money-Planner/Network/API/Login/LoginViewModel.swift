//
//  LoginViewModel.swift
//  Money-Planner
//
//  Created by p_kxn_g on 3/7/24.
//

import Foundation
import RxSwift
import RxMoya
import Moya
import UIKit

class LoginViewModel {
    let loginRepository = LoginRepository()
    let disposeBag = DisposeBag()
    
    func isLoginEnabled() -> Observable<Bool> {
        print("log : 로그인 확인 중입니다.----------------------")
        return loginRepository.connect()
            .map { response -> Bool in
                // 성공적인 응답 처리
                print("[ 로그인 시도 ] success - \(response)")
                return response.isSuccess
            }
            .catch { error -> Observable<Bool> in
                // 오류 발생 시 로깅
                print("[ 로그인 시도 ] Login error: \(error.localizedDescription)")
                // 오류 유형에 따른 분기 처리가 필요한 경우 여기서 수행
                // 예: if error is SomeSpecificError { ... }
                return Observable.just(false) // 일반적으로 로그인 불가능으로 처리
            }
    }



   
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let topViewController = windowScene.windows.first?.rootViewController {
//            let alertController = UIAlertController(title: "로그인 세션 만료", message: "보안상의 이유로 다시 로그인이 필요합니다. 자동으로 로그인을 시도합니다.", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
//            topViewController.present(alertController, animated: true, completion: nil)
//        }
    func refreshAccessTokenIfNeeded() -> Observable<Bool> {
        print("log: 엑세스 토큰 갱신 시도")

        guard let refreshToken = TokenManager.shared.refreshToken else {
            print("log: 리프레시 토큰이 없음")
            handleFailedTokenRefresh(message: "리프레시 토큰이 없습니다.")
            return Observable.just(false)
        }

        let refreshTokenRequest = RefreshTokenRequest(refreshToken: refreshToken)
        return loginRepository.refreshToken(refreshToken: refreshTokenRequest)
            .map { response in
                if response.isSuccess {
                    print("결과 : 성공 - 엑세스 토큰 갱신 ")
                    if let result = response.result {
                        let accessToken = result.accessToken
                        let refreshToken = result.refreshToken
                        self.handleSuccessfulTokenRefresh(accessToken: accessToken, refreshToken: refreshToken)
                    }
                    return true
                } else {
                    print("결과 : 실패 - 엑세스 토큰 갱신 실패 > 리프레쉬 토큰 갱신 필요 ")
                    self.handleFailedTokenRefresh(message: response.message)
                    return false
                }
            }
            .do(onNext: { response in
                print("log: 토큰 갱신 응답 수신, 응답: \(response)")
            }, onError: { error in
                if let moyaError = error as? MoyaError, let response = moyaError.response {
                    let responseBody = String(data: response.data, encoding: .utf8) ?? "Unable to decode response body"
                    print("log: 토큰 갱신 요청 실패, 에러: \(error), 응답: \(responseBody)")
                } else {
                    print("log: 토큰 갱신 요청 실패, 에러: \(error)")
                }
                self.handleFailedTokenRefresh(message: error.localizedDescription)
            })
            .catchAndReturn(false)
    }



    private func handleSuccessfulTokenRefresh(accessToken : String, refreshToken:String) {
        print("Successfully refreshed token")
        TokenManager.shared.handleLoginSuccess(accessToken: accessToken, refreshToken: refreshToken)
        DispatchQueue.main.async {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.moveToHome()
        }
    }

    private func handleFailedTokenRefresh(message: String) {
        print("Failed to refresh token: \(message)")
        DispatchQueue.main.async {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.moveToLogin()
        }
    }

    private func handleError(error: Error) {
        print("Error occurred: \(error.localizedDescription)")
        DispatchQueue.main.async {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.moveToLogin()
        }
    }
    // 프로필 설정 함수
    func join(name : String, img : String, completion: @escaping (Bool) -> Void){
        print(name, img)
        let request = JoinRequest(name: name, profileImg: img)
        
        loginRepository.join(request: request)
            .subscribe(onNext: { response in
                print(response)
               
                if response.isSuccess == false {
                    completion(false)
                    DispatchQueue.main.async {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let topViewController = windowScene.windows.first?.rootViewController {
                            let alertController = UIAlertController(title: "프로필 설정 실패", message: "프로필 설정을 실패하였습니다. 다시 시도해주세요.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                            topViewController.present(alertController, animated: true, completion: nil)
                        }
                    }
                }else{
                    completion(true)
                }
            }, onError: { error in
                // 오류가 발생한 경우에 대한 처리를 수행합니다.
                completion(false)
                print(error)
                print("Error refreshing access token: \(error.localizedDescription)")
                // Display an alert
                           DispatchQueue.main.async {
                               if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                  let topViewController = windowScene.windows.first?.rootViewController {
                                   let alertController = UIAlertController(title: "프로필 설정 실패", message: "프로필 설정을 실패하였습니다. 다시 시도해주세요.", preferredStyle: .alert)
                                   alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                   topViewController.present(alertController, animated: true, completion: nil)
                               }
                           }
            })
            .disposed(by: disposeBag)
    }

    // 토큰이 없는 경우 > 로그인 화면
    func login(socialType:LoginRequest.SocialType, idToken:String){
        print(socialType, idToken)
        //print("로그인 api 연결")
        let request = LoginRequest(socialType: socialType, token: idToken) // idToken -> token으로 변수명 변경
        loginRepository.login(request: request)
            .subscribe(onNext: { response in
                print(response)
                if response.isSuccess == true {
                    
                    if let result = response.result {
                        if let tokenInfo = result.tokenInfo, let newMember = result.newMember {
                            // 토큰 업데이트
                            TokenManager.shared.handleLoginSuccess(accessToken: tokenInfo.accessToken, refreshToken: tokenInfo.accessToken )
                            print("토큰 업데이트 완료 ------------------------------------------------")
                            print("엑세스 토큰 : ", String(TokenManager.shared.accessToken ?? "nil"))
                            print("리프레쉬 토큰 : ",  String(TokenManager.shared.refreshToken ?? "nil"))
                            print("------------------------------------------------")
                            
                            if newMember {
                                print("새로운 회원 : 온보딩 화면으로 이동")
                                // 온보딩 화면으로 이동
                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                    sceneDelegate.moveToOnBoarding()
                                }                        }else{
                                print("원래 있던 회원 : 홈 화면으로 이동")
                                // 홈 화면으로 이동
                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                    sceneDelegate.moveToHome()
                                }
                            }
                        }
                    }

                    
                }
            }, onError: { error in
                // 오류가 발생한 경우에 대한 처리를 수행합니다.
                print(error)
                print("Error refreshing access token: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
}

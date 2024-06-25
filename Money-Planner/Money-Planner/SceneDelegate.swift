//
//  SceneDelegate.swift
//  Money-Planner
//
//  Created by 유철민 on 1/5/24.
//

import UIKit
import KakaoSDKAuth
import AuthenticationServices
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
             
    var window: UIWindow?
    private let disposeBag = DisposeBag()
    
     // 앱이 시작될 때 초기 화면 설정
     func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
         // UIWindowScene 유효성 검사
         guard let windowScene = (scene as? UIWindowScene) else { return }
//        TokenManager.shared.clearTokens() // 토큰 삭제

//         TokenManager.shared.handleLoginSuccess(accessToken: "test", refreshToken: TokenManager.shared.refreshToken ?? "")
         window = UIWindow(windowScene: windowScene)
         checkAndRefreshToken() // 토큰 확인 후 화면 이동 로직 진행
         
         self.window?.makeKeyAndVisible()
     }
    
    // 토큰 확인 후 화면 이동
    private func checkAndRefreshToken() {
        let isLoggedIn = TokenManager.shared.isLoggedIn() // 저장된 토큰이 있는 확인 -> 있으면 true , 없으면 false
        
        if isLoggedIn {
            print("저장된 토큰이 있습니다 --> 홈화면으로 이동합니다")
            tryConnect() // 토큰 갱신 시도
        } else {
            print("저장된 토큰이 없습니다 --> 로그인 화면으로 이동")
            self.moveToLogin() // 로그인 화면으로 이동
        }
        
    }
    // api 연결 시도
    private func tryConnect(){
        let loginRepository = LoginRepository()
        // 3. 토큰 갱신 시도
        loginRepository.connect()
            .subscribe(onNext: { [weak self] response in
                if response.isSuccess {
                    print("결과 : 성공 - api 연결 시도 > 현재 토큰 이상 없음 ")
                    self?.setupMainInterface()
                } else {
                    self?.refreshAccessTokenIfNeeded()
                }
            }, onError: { [weak self] error in
                self?.refreshAccessTokenIfNeeded()
            })
            .disposed(by: disposeBag)
        
    }
    // 토큰 갱신 함수
    private func refreshAccessTokenIfNeeded() {
        
        // 1. 엑세스 토큰 갱신에 필요한 리프레시 토큰 가져오기
        guard let refreshToken = TokenManager.shared.refreshToken else {
            print("[log] 리프레시 토큰이 없습니다 --> 로그인 화면으로 이동")
            self.moveToLogin()
            return
        }
        
        // 2. 토큰 갱신 api 연결에 필요한 요청 및 초기화
        let refreshTokenRequest = RefreshTokenRequest(refreshToken: refreshToken)
        let loginRepository = LoginRepository()
        
        // 3. 토큰 갱신 시도
        loginRepository.refreshToken(refreshToken: refreshTokenRequest)
            .subscribe(onNext: { [weak self] response in
                if response.isSuccess {
                    print("결과 : 성공 - 엑세스 토큰 갱신 ")
                    
                    // 3-1. 토큰 갱신 성공 - 엑세스, 리프레쉬 토큰 다시 저장
                    if let result = response.result {
                        let accessToken = result.accessToken
                        let refreshToken = result.refreshToken
                        TokenManager.shared.handleLoginSuccess(accessToken: accessToken, refreshToken: refreshToken)
                        self?.setupMainInterface()
                    }
                } else {
                    
                    // 3-2. 토큰 갱신 실패 - 로그인 화면으로 이동
                    print("결과 : 실패 - 엑세스 토큰 갱신 실패")
                    self?.moveToLogin()
                }
            }, onError: { [weak self] error in
                
                // 3-3. 토큰 갱신 api 연결 실패 - 로그인 화면으로 이동
                print("토큰 갱신 요청 실패, 에러: \(error)")
                self?.moveToLogin()
            })
            .disposed(by: disposeBag)
    }
     
     // 메인 인터페이스 설정
     func setupMainInterface() {
         let tabBarController = CustomTabBarController()
         tabBarController.tabBar.tintColor = .mpMainColor

         let homeVC = UINavigationController(rootViewController: HomeViewController())
         let goalVC = UINavigationController(rootViewController: GoalMainViewController())
         let consumeVC = UINavigationController(rootViewController: ConsumeViewController())
         let battleVC = UINavigationController(rootViewController: BattleViewController())
         let settingVC = UINavigationController(rootViewController: MyPageViewController())
         
         homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "home"), tag: 0)
         goalVC.tabBarItem = UITabBarItem(title: "목표", image: UIImage(named: "btn_goal_on"), tag: 1)
         consumeVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "btn_add_new")?.withRenderingMode(.alwaysOriginal), selectedImage: nil)
         battleVC.tabBarItem = UITabBarItem(title: "소비 배틀", image: UIImage(named: "btn_battle_on"), tag: 3)
         settingVC.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(named: "btn_mypage_on"), tag: 4)

         tabBarController.viewControllers = [homeVC, goalVC, consumeVC, battleVC, settingVC]
         tabBarController.selectedIndex = 0 // 홈을 기본 선택 탭으로 설정

         window?.rootViewController = tabBarController
//         let vc = EditGoalViewController(1)
//         let VC = UINavigationController(rootViewController: vc)
//         window?.rootViewController = VC
     }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 애플 Id 확인
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let defaults = UserDefaults.standard
//        if let userID = defaults.string(forKey: "userIdentifier"){
//            appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
//                switch credentialState {
//                    case .authorized:
//                       print("authorized")
//                       // The Apple ID credential is valid.
//                       DispatchQueue.main.async {
//                         //authorized된 상태이므로 바로 로그인 완료 화면으로 이동
//                           self.setupMainInterface()
//                       }
//                    case .revoked:
//                       print("revoked")
//                    case .notFound:
//                       // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
//                       print("notFound")
//                           
//                    default:
//                        break
//                }
//            }
//            
//        }
//
//        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
            if let url = URLContexts.first?.url {
                if (AuthApi.isKakaoTalkLoginUrl(url)) {
                    _ = AuthController.handleOpenUrl(url: url)
                }
            }
        }
    
    func moveToHome(){
        print("홈화면으로 이동")
        DispatchQueue.main.async {
            self.setupMainInterface()
        }

    }
    
    func moveToLogin() {
        print("로그인 화면으로 이동")
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            // 루트 뷰 컨트롤러를 로그인 뷰 컨트롤러로 설정하면서 애니메이션 적용
                if let window = self.window {
                    // 애니메이션과 함께 루트 뷰 컨트롤러 변경
                    UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = LoginViewController()
                        self.window?.makeKeyAndVisible()
                    })
                }
          
        }
    }
    
    func moveToOnBoarding(){
        print("온보딩 화면으로 이동 - 프로필 입력")
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            if let window = windowScene.windows.first {
                let onBoardingVC = OnBoardingProfileViewController()
                let navigationController = UINavigationController(rootViewController: onBoardingVC)
                if let chevronImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal) {
                    let backButton = UIButton(type: .custom)
                    
                    chevronImage.withTintColor(.black) // 뒤로가기 버튼 : 검정색 적용
                    backButton.setImage(chevronImage, for: .normal)
                    backButton.tintColor = .mpBlack
                    
                    let buttonSize: CGFloat = 40 // 버튼의 크기 설정
                    backButton.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize) // 버튼의 프레임 설정
                    
                    backButton.addTarget(self, action: #selector(self.cancelOnBoarding), for: .touchUpInside)
                    onBoardingVC.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
                }
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }
    }
    func moveToOnBoardingExplain() {
        print("다음 온보딩 화면으로 이동 - 앱 설명")
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            if let window = windowScene.windows.first {
                let onBoardingVC = OnboardingViewController()
                let navigationController = UINavigationController(rootViewController: onBoardingVC)
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }
    }
    func moveToOnBoardingNotification() {
        print("다음 온보딩 화면으로 이동 - 알람")
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            if let window = windowScene.windows.first {
                let onBoardingVC = OnboardingNotificationViewController()
                let navigationController = UINavigationController(rootViewController: onBoardingVC)
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }
    }

   
    @objc func cancelOnBoarding() {
        print("온보딩 취소")
        moveToLogin()
        // 저장한 토큰 삭제
        TokenManager.shared.clearTokens()

    }

    
    
}

extension SceneDelegate {
    func changeRootVC(_ vc:UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        window.rootViewController = vc // 전환
        
        UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
      }
}


// 토큰 수동으로 넣는 코드 - by. 근영 -----------------------------------------------------------
//     TokenManager.shared.handleLoginSuccess(accessToken: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMzI0NjEzNzk1IiwiYXV0aCI6IlVTRVIiLCJleHAiOjE3MTY1NzIxMDh9.Vb0JSZPhaTuLs7JqoSlBkOSuAc-9BLj0065XnzD13hI", refreshToken: "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE3MTkwNzc3MDh9.W3WkUHWtETcBl_wXUUXGqJWsKLvojwRHK-cN1163F-Q")
//     TokenManager.shared.clearTokens() // 토큰 삭제
//     print("토큰 확인", TokenManager.shared.accessToken, TokenManager.shared.refreshToken) // 토큰 확인 코드
// ----------------------------------------------------------------------------------------

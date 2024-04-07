//
//  SceneDelegate.swift
//  Money-Planner
//
//  Created by 유철민 on 1/5/24.
//

import UIKit
import KakaoSDKAuth
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
     
     // 앱이 시작될 때 초기 화면 설정
     func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
         // UIWindowScene 유효성 검사
         guard let windowScene = (scene as? UIWindowScene) else { return }
         window = UIWindow(windowScene: windowScene)
         // login api 연결
         let viewModel = LoginViewModel()
         let disposeBag = viewModel.disposeBag
         //TokenManager.shared.clearTokens() // 토큰 삭제
         let isLoggedIn = TokenManager.shared.isLoggedIn() // 엑세스 토큰 있는지 여부
         print(isLoggedIn)
         if isLoggedIn {
             print("로그인 한 적 있음")
             self.setupMainInterface()
//              // 가진 토큰으로 로그인 시도
//             viewModel.isLoginEnabled()
//                 .subscribe(onNext: { isEnabled in
//                     if isEnabled {
//                         print("로그인 가능 > 홈화면으로 이동")
//                         // 홈화면으로 이동
//                          self.setupMainInterface()
//                     } else {
//                         print("로그인 불가능 > 토큰 갱신 시도")
//                     }
//                 })
//                 .disposed(by: disposeBag)
         } else {
             print("토큰 없음")
             // 로그인 화면으로 이동
             DispatchQueue.main.async {
                 self.window?.rootViewController = LoginViewController()
                 
             }
         }
         self.window?.makeKeyAndVisible()
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
        print("온보딩 화면으로 이동")
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

   
    @objc func cancelOnBoarding() {
        print("온보딩 취소")
        moveToLogin()
        // 저장한 토큰 삭제
        TokenManager.shared.clearTokens()

    }

    
    
}


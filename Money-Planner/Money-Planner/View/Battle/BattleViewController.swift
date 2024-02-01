//
//  BattleViewController.swift
//  Money-Planner
//
//  Created by 유철민 on 1/6/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BattleViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel = MyViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mpWhite

        // 사용자명을 입력하는 UITextField
        let usernameTextField = UITextField()
        usernameTextField.placeholder = "GitHub Username"
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameTextField)

        // 검색 버튼
        let searchButton = UIButton(type: .system)
        searchButton.setTitle("검색", for: .normal)
        searchButton.backgroundColor = .mpGypsumGray
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchButton)
        
        let apiResultLabel = UILabel()
        apiResultLabel.text = "API 결과 나옴"
        apiResultLabel.numberOfLines = 0  // Set to 0 for multiple lines
        apiResultLabel.lineBreakMode = .byWordWrapping  // or .byWordWrapping
        apiResultLabel.translatesAutoresizingMaskIntoConstraints = false
        apiResultLabel.textAlignment = .center
        view.addSubview(apiResultLabel)
        
        // Add constraints for usernameTextField
        NSLayoutConstraint.activate([
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            usernameTextField.widthAnchor.constraint(equalToConstant: 150),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Add constraints for searchButton
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 100),
            searchButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            apiResultLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: -5),
            apiResultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            apiResultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            apiResultLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
        
        // API 호출 및 결과를 구독
        searchButton.rx.tap
            .withLatestFrom(usernameTextField.rx.text.orEmpty)
            .flatMapLatest { username in
                return self.viewModel.getUserRepos(username: username)
                    .asObservable()
                    .catchError { error in
                        print("Error: \(error)")
                        return Observable.just([]) // Provide a default value or handle the error appropriately
                    }
            }
            .observeOn(MainScheduler.instance)
               .subscribe(onNext: { repos in
                   print(repos)
                   apiResultLabel.text = "\(repos)"
                   // 여기에서 가져온 데이터로 UI 업데이트 등을 수행
               })
               .disposed(by: disposeBag)
    }
}

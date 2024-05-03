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
    let viewModel = MufflerViewModel()
    let titleLabel : MPLabel = {
        let label = MPLabel()
        label.text = "친구와 배틀하기"
        label.font = .mpFont20B()
        label.textColor = .mpBlack
        return label
    }()
    let imgView : UIImageView = {
        let v = UIImageView()
        let image = UIImage(named:"goal-create" )
        v.image = image
        return v
    }()
    let contentLabel1 : MPLabel = {
        let label = MPLabel()
        label.font = .mpFont14M()
        label.textColor = .mpDarkGray
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "배틀 기능은 아직 준비 중..."
        return label
    }()
    let contentLabel2 : MPLabel = {
        let label = MPLabel()
        label.font = .mpFont14M()
        label.textColor = .mpDarkGray
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "조금만 기다려주세요!"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mpWhite
        // 네비게이션 바 숨기기
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        setupTitle()
        setupContents()
        
    
    }
    private func setupTitle(){
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
    }
    private func setupContents(){
        let container = UIScrollView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let battleImage = UIImageView(image: UIImage(named: "img_battle_prepare"))
        battleImage.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(container)
        container.addSubview(battleImage)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            battleImage.widthAnchor.constraint(equalTo: container.frameLayoutGuide.widthAnchor),
            battleImage.topAnchor.constraint(equalTo: container.topAnchor),
            battleImage.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            battleImage.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            battleImage.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        
        ])


    }

   
}


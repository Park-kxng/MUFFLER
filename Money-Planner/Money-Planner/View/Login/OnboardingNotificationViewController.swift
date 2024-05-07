//
//  OnboardingNotificationViewController.swift
//  Money-Planner
//
//  Created by Jini on 3/22/24.
//

import UIKit

class OnboardingNotificationViewController: UIViewController {
    
    let titleLabel = MPLabel()
    let descLabel = MPLabel()
    
    let confirmBtn = UIButton()
    let denyBtn = UIButton()
    
    let imgView = UIImageView()
    
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.mpWhite
        
        setupNavigationBar()
        setupText()
        setupImg()
        setupButton()
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "알림 설정"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mpBlack, NSAttributedString.Key.font: UIFont.mpFont18B()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        
    }
    
    func setupText() {
        titleLabel.numberOfLines = 0
        descLabel.numberOfLines = 0
        
        titleLabel.font = UIFont.mpFont26B()
        descLabel.font = UIFont.mpFont16M()
        
        titleLabel.textColor = UIColor.mpBlack
        descLabel.textColor = UIColor.mpDarkGray
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.lineSpacing = 5
        let titleAttributedString = NSAttributedString(string: "알림을 통해 목표를\n매일 리마인드 해드릴게요", attributes: [NSAttributedString.Key.paragraphStyle: titleParagraphStyle])
        titleLabel.attributedText = titleAttributedString
        
        let descParagraphStyle = NSMutableParagraphStyle()
        descParagraphStyle.lineSpacing = 5
        let descAttributedString = NSAttributedString(string: "나의 소비목표를 잊지 않도록 도와드릴게요", attributes: [NSAttributedString.Key.paragraphStyle: descParagraphStyle])
        descLabel.attributedText = descAttributedString
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
    }
    
    func setupImg() {
        imgView.image = UIImage(named: "img_onboard_05alert")
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imgView)
        
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 65),
            imgView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imgView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            imgView.heightAnchor.constraint(equalToConstant: 323)
        ])
        
    }
    
    
    func setupButton() {
        confirmBtn.backgroundColor = UIColor.mpMainColor
        confirmBtn.setTitle("알림 받기", for: .normal)
        confirmBtn.setTitleColor(UIColor.mpWhite, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.mpFont18B()
        confirmBtn.layer.cornerRadius = 12
        
        denyBtn.backgroundColor = UIColor.mpWhite
        denyBtn.titleLabel?.font = UIFont.mpFont16M()
        
        let denyAttributedTitle = NSAttributedString(string: "알림 안 받을래요", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor.mpDarkGray])
        denyBtn.setAttributedTitle(denyAttributedTitle, for: .normal)
        
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        denyBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmBtn)
        view.addSubview(denyBtn)
        
        NSLayoutConstraint.activate([
            confirmBtn.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            confirmBtn.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            confirmBtn.bottomAnchor.constraint(equalTo: denyBtn.topAnchor, constant: -16),
            confirmBtn.heightAnchor.constraint(equalToConstant: 56),
            
            denyBtn.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            denyBtn.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            denyBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            denyBtn.heightAnchor.constraint(equalToConstant: 24),
            
            
        ])
        
        confirmBtn.addTarget(self, action: #selector(confirmBtnPressed), for: .touchUpInside)
        denyBtn.addTarget(self, action: #selector(denyBtnPressed), for: .touchUpInside)
            
    }
    
    
    @objc func confirmBtnPressed() {
        //알림 수신 설정
        //HomeViewController로 루트뷰 설정
        print("알림 수신 설정")
        let vc = HomeViewController()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(vc, animated: false)
    }
    
    @objc func denyBtnPressed() {
        //알림 거부 설정
        //HomeViewController로 루트뷰 설정
        print("알림 거부 설정")
        let vc = HomeViewController()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(vc, animated: false)
    }
    
}

extension OnboardingViewController {
    
    
}

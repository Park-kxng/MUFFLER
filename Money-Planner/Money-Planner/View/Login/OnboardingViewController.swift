//
//  OnboardingViewController.swift
//  Money-Planner
//
//  Created by Jini on 3/21/24.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    var contentPages = [UIViewController]()
    var currentPageIndex = 0
    
    let pageSize = 4
    
    let titleLabel = MPLabel()
    let descLabel = MPLabel()
    
    lazy var pageControl = UIPageControl()
    
    let nextBtn = UIButton()
    
    let imgView = UIImageView()
    
    let settingData: [(titleText: String, descText: String, imgName: String)] = [
        ("목표 진행 현황을 한 눈에!", "홈화면의 그래프와 캘린더로\n진행상황을 쉽게 확인해요", "img_onboard_01"),
        ("내 스케줄에 맞게,\n하루 단위로 디테일한 목표", "기간에 맞게 1/n된 목표 금액을 손쉽게 조정해요", "img_onboard_02"),
        ("오늘 나의 소비를\n직접 평가해볼까요?", "매일매일 스스로에게 피드백을 줘요", "img_onboard_03"),
        ("내 목표를 자세히\n분석해준 레포트까지", "목표 진행상황을 자세히 살펴보아요", "img_onboard_04")
    ]
    
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.mpWhite
        
        setupText()
        setupImg()
        setupButton()
        setupPageControl()
        
        updateContentForPage(currentPageIndex)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func updateContentForPage(_ pageIndex: Int) {
        let content = settingData[pageIndex]
        titleLabel.text = content.titleText
        descLabel.text = content.descText
        imgView.image = UIImage(named: content.imgName)
        
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
        let titleAttributedString = NSAttributedString(string: "Title Text", attributes: [NSAttributedString.Key.paragraphStyle: titleParagraphStyle])
        titleLabel.attributedText = titleAttributedString
        
        let descParagraphStyle = NSMutableParagraphStyle()
        descParagraphStyle.lineSpacing = 5
        let descAttributedString = NSAttributedString(string: "Description Text", attributes: [NSAttributedString.Key.paragraphStyle: descParagraphStyle])
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
        imgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imgView)
        
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: -10),
            imgView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            imgView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            imgView.heightAnchor.constraint(equalToConstant: 600)
        ])
        
    }
    
    func setupPageControl() {
        pageControl.backgroundColor = UIColor.mpWhite
        pageControl.numberOfPages = pageSize
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        pageControl.pageIndicatorTintColor = UIColor.mpLightGray
        pageControl.currentPageIndicatorTintColor = UIColor.mpMainColor
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: nextBtn.topAnchor, constant: -28),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 8)
        
        
        ])
    }
    
    
    func setupButton() {
        nextBtn.backgroundColor = UIColor.mpMainColor
        nextBtn.setTitle("다음", for: .normal)
        nextBtn.setTitleColor(UIColor.mpWhite, for: .normal)
        nextBtn.titleLabel?.font = UIFont.mpFont18B()
        nextBtn.layer.cornerRadius = 12
        
        nextBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextBtn)
        
        NSLayoutConstraint.activate([
            nextBtn.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nextBtn.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nextBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            nextBtn.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        nextBtn.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
            
    }
    
    
    @objc func nextButtonPressed() {
        currentPageIndex += 1
        if currentPageIndex < pageSize {
            UIView.transition(with: imgView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.updateContentForPage(self.currentPageIndex)
            }, completion: nil)
            pageControl.currentPage = currentPageIndex
            if currentPageIndex == 3 {
                nextBtn.setTitle("시작하기", for: .normal)
            }
        } else {
            let vc = OnboardingNotificationViewController()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // 한 손가락 스와이프 제스쳐를 행했을 때 실행할 액션 메서드
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 제스쳐가 있다면
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                if currentPageIndex < pageSize - 1 {
                    currentPageIndex += 1
                    updateContentForPage(currentPageIndex)
                    pageControl.currentPage = currentPageIndex
                    if currentPageIndex == 3 {
                        nextBtn.setTitle("시작하기", for: .normal)
                    }
                }
            case UISwipeGestureRecognizer.Direction.right:
                if currentPageIndex > 0 {
                    currentPageIndex -= 1
                    updateContentForPage(currentPageIndex)
                    pageControl.currentPage = currentPageIndex
                    nextBtn.setTitle("다음", for: .normal)
                }
            default:
                break
            }
        }
    }
    
}

extension OnboardingViewController {
    
    
}

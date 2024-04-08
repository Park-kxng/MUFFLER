//
//  GoalExpenseFilterModal.swift
//  Money-Planner
//
//  Created by 유철민 on 3/20/24.
//

import Foundation
import UIKit
import RxSwift
import FSCalendar
import Lottie

protocol GoalExpenseFilterDelegate {
    func selectPeriod()
    func selectCategory()
}

class GoalExpenseFilterModal: UIViewController {
    
    var delegate: GoalExpenseFilterDelegate?
    
    // 구성요소
    let customModal = UIView()
    let grabber : UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .mpLightGray
        uiView.layer.cornerRadius = 4
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    let titleLabel: MPLabel = {
        let label = MPLabel()
        label.text = "소비내역 조회 필터링"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let periodButton: CustomButton = {
        let btn = CustomButton()
        btn.backgroundColor = .clear
        btn.setTitle("조회 기간 선택", for: .normal)
        btn.setImage(UIImage(named: "icon_date"), for: .normal)
        btn.setTitleColor(.mpBlack, for: .normal)
        btn.tintColor = .mpGray
        btn.titleLabel?.font = .mpFont18M()
        btn.addTarget(self, action: #selector(periodBtnTapped), for: .touchUpInside)
        
        // Adjust contentEdgeInsets if needed to ensure content fits within the button
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        return btn
    }()

    
    let seperator : UIView = {
        let view = UIView()
        view.backgroundColor = .mpLightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let categoryButton: CustomButton = {
        let btn = CustomButton()
        btn.backgroundColor = .clear
        btn.setTitle("조회 카테고리 선택", for: .normal)
        btn.setImage(UIImage(named: "_icon_filter"), for: .normal)
        btn.setTitleColor(.mpBlack, for: .normal)
        btn.tintColor = .mpGray
        btn.titleLabel?.font = .mpFont18M()
        btn.addTarget(self, action: #selector(categoryBtnTapped), for: .touchUpInside)

        // Adjust contentEdgeInsets if needed to ensure content fits within the button
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        return btn
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear // Replace with .mpWhite if it's a custom color in your project
        setupLayoutConstraints()
    }
    
    @objc func periodBtnTapped(){
        delegate!.selectPeriod()
    }
    
    @objc func categoryBtnTapped(){
        delegate!.selectCategory()
    }
    
    private func setupLayoutConstraints() {
        
        view.addSubview(customModal)
        view.addSubview(grabber)
        view.addSubview(titleLabel)
        view.addSubview(periodButton)
        view.addSubview(seperator)
        view.addSubview(categoryButton)
      
        // Assuming customModal is a container view that holds all your subviews
        
        customModal.backgroundColor = .mpWhite
        customModal.layer.cornerRadius = 25
        customModal.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customModal.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            customModal.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            customModal.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            customModal.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        grabber.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        periodButton.translatesAutoresizingMaskIntoConstraints = false
        seperator.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            grabber.topAnchor.constraint(equalTo: customModal.topAnchor, constant: 12),
            grabber.centerXAnchor.constraint(equalTo: customModal.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 49),
            grabber.heightAnchor.constraint(equalToConstant: 4),
        ])
        
        // Constraints for titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 25),
            titleLabel.leadingAnchor.constraint(equalTo: customModal.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: customModal.trailingAnchor, constant: -24),
            titleLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        NSLayoutConstraint.activate([
            periodButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            periodButton.leadingAnchor.constraint(equalTo: customModal.leadingAnchor, constant: 24),
            periodButton.trailingAnchor.constraint(equalTo: customModal.trailingAnchor, constant: -24),
            periodButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        NSLayoutConstraint.activate([
            
        ])
        
        NSLayoutConstraint.activate([
            seperator.topAnchor.constraint(equalTo: periodButton.bottomAnchor, constant: 1),
            seperator.leadingAnchor.constraint(equalTo: customModal.leadingAnchor, constant: 24),
            seperator.trailingAnchor.constraint(equalTo: customModal.trailingAnchor, constant: -24),
            seperator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: seperator.bottomAnchor, constant: 1),
            categoryButton.leadingAnchor.constraint(equalTo: customModal.leadingAnchor, constant: 24),
            categoryButton.trailingAnchor.constraint(equalTo: customModal.trailingAnchor, constant: -24),
            categoryButton.heightAnchor.constraint(equalToConstant: 70),
            categoryButton.bottomAnchor.constraint(lessThanOrEqualTo: customModal.bottomAnchor, constant: -24)
        ])
        
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        grabber.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if translation.y > 0 { // Dismiss only on dragging down
            view.transform = CGAffineTransform(translationX: 0, y: translation.y)
        }
        
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: view)
            if velocity.y >= 1500 { // If the speed of dragging is high enough, dismiss
                self.dismiss(animated: true)
            } else {
                // Return to original position
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                }
            }
        }
    }
    
}


class CustomButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = self.imageView, let titleLabel = self.titleLabel {
            imageView.frame.origin.x = self.bounds.minX // Image to the left
            imageView.frame.origin.y = (self.bounds.height - imageView.frame.height) / 2 // Vertically center
            
            titleLabel.frame.origin.x = (self.bounds.width - titleLabel.frame.width) / 2 // Title centered
            titleLabel.frame.origin.y = (self.bounds.height - titleLabel.frame.height) / 2 // Vertically center
        }
    }
}

//
//  goalDeleteModalView.swift
//  Money-Planner
//
//  Created by Jini on 2024/02/04.
//

import Foundation
import UIKit
import Lottie

protocol goalDeleteModalDelegate {
    func deleteGoal()
}

class goalDeleteModalView : UIViewController {
    
    let goalName: String
    
    init(goalName: String) {
        self.goalName = goalName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate : goalDeleteModalDelegate?
    let customModal = UIView(frame: CGRect(x: 0, y: 0, width: 322, height: 400))
    
    let titleLabel: MPLabel = {
        let label = MPLabel()
        label.text = ""
        label.numberOfLines = 0
        label.font = UIFont.mpFont20B()
        
        return label
    }()
    
    let contentLabel : MPLabel = {
        let label = MPLabel()
        label.text = ""
        label.numberOfLines = 0
        label.font = UIFont.mpFont16M()
        
        return label
    }()
    
    let ImageView : LottieAnimationView = {
        let animationView: LottieAnimationView = .init(name: "muffler_delete")
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 2
        animationView.translatesAutoresizingMaskIntoConstraints = false
        return animationView
    }()
    
    let controlButtons = SmallBtnView()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(UIColor.mpMainColor, for: .normal)
        button.backgroundColor = UIColor.mpWhite
        button.layer.borderColor = UIColor.mpMainColor.cgColor
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(UIColor.mpWhite, for: .normal)
        button.backgroundColor = UIColor.mpMainColor
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentCustomModal()
        setupBackground()
        setupdeleteView()
        
        controlButtons.addCancelAction(target: self, action: #selector(cancelButtonTapped))
        controlButtons.addCompleteAction(target: self, action: #selector(deleteButtonTapped))
        
        ImageView.play()
    }
    
    @objc func cancelButtonTapped() {
        print("취소 버튼이 탭되었습니다.")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteButtonTapped() {
        print("삭제 버튼이 탭되었습니다.")
        // 삭제 버튼 액션 처리
        dismiss(animated: true){
            self.delegate?.deleteGoal()
        }
    }
    
    func presentCustomModal() {
        customModal.backgroundColor = UIColor.mpWhite
        view.addSubview(customModal)
        customModal.center = view.center
    }
    
    private func setupBackground() {
        view.backgroundColor = UIColor.mpDim
        customModal.layer.cornerRadius = 25
        customModal.layer.masksToBounds = true
    }
    
    private func setupdeleteView() {
        customModal.addSubview(titleLabel)
        customModal.addSubview(contentLabel)
        customModal.addSubview(ImageView)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let titleAttributedText = NSAttributedString(string: "[" + goalName + "]\n목표를 정말 삭제하시겠어요?", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        titleLabel.attributedText = titleAttributedText
        titleLabel.textAlignment = .center
       
        let contentAttributedText = NSAttributedString(string: "소비내역은 임시보관 되므로, 다음\n목표를 설정할 때 되살릴 수 있어요", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        contentLabel.attributedText = contentAttributedText
        contentLabel.textAlignment = .center
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        ImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: customModal.topAnchor, constant: 35),
            titleLabel.centerXAnchor.constraint(equalTo: customModal.centerXAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            contentLabel.centerXAnchor.constraint(equalTo: customModal.centerXAnchor),
            
            ImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 15),
            ImageView.centerXAnchor.constraint(equalTo: customModal.centerXAnchor),
        ])
        
        customModal.addSubview(controlButtons)
        controlButtons.translatesAutoresizingMaskIntoConstraints = false
        
        controlButtons.cancelButton.setTitle("취소", for: .normal)
        controlButtons.completeButton.setTitle("삭제", for: .normal)
        
        NSLayoutConstraint.activate([
            controlButtons.topAnchor.constraint(greaterThanOrEqualTo: ImageView.bottomAnchor, constant: 15),
            controlButtons.leadingAnchor.constraint(equalTo: customModal.leadingAnchor, constant: 15),
            controlButtons.trailingAnchor.constraint(equalTo: customModal.trailingAnchor, constant: -15),
            controlButtons.heightAnchor.constraint(equalToConstant: 58),
            controlButtons.bottomAnchor.constraint(equalTo: customModal.bottomAnchor, constant: -15)
        ])
    }

    
}

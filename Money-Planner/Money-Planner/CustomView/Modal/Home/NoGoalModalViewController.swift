
import Foundation
import UIKit

class NoGoalModalViewController : UIViewController {
    
    private let titleLabel : MPLabel = {
        let label = MPLabel()
        label.text = "목표가 없는 날이에요"
        label.font = .mpFont20B()
        label.textColor = .mpBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel1 : MPLabel = {
        let label = MPLabel()
        label.text = "목표를 만든 후, 목표를 바탕으로"
        label.font = .mpFont16M()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let contentLabel2 : MPLabel = {
        let label = MPLabel()
        label.text = "오늘 하루의 소비를 평가해보아요"
        label.font = .mpFont16M()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.layer.borderColor = UIColor.mpMainColor.cgColor
        button.setTitleColor(.mpMainColor, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let customModal: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("목표 생성하기", for: .normal)
        button.backgroundColor = UIColor.mpMainColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        view.addSubview(customModal)
        customModal.addSubview(titleLabel)
        customModal.addSubview(contentLabel1)
        customModal.addSubview(contentLabel2)
        customModal.addSubview(doneButton)
        customModal.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            customModal.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customModal.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            customModal.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64),
            customModal.heightAnchor.constraint(equalToConstant: 242),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: customModal.topAnchor, constant: 36),
            
            contentLabel1.centerXAnchor.constraint(equalTo: customModal.centerXAnchor),
            contentLabel1.centerYAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36),
            contentLabel2.centerXAnchor.constraint(equalTo: customModal.centerXAnchor),
            contentLabel2.centerYAnchor.constraint(equalTo: contentLabel1.bottomAnchor, constant: 8),
            
            
            doneButton.leadingAnchor.constraint(equalTo: customModal.centerXAnchor, constant: 4),
            doneButton.bottomAnchor.constraint(equalTo: customModal.bottomAnchor, constant: -20),
            doneButton.trailingAnchor.constraint(equalTo: customModal.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 56),
            
            cancelButton.bottomAnchor.constraint(equalTo: customModal.bottomAnchor, constant: -20),
            cancelButton.leadingAnchor.constraint(equalTo: customModal.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: customModal.centerXAnchor, constant: -4),
            cancelButton.heightAnchor.constraint(equalToConstant: 56),
            
        ])
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("openAddGoal"), object: nil)
    }
    
}



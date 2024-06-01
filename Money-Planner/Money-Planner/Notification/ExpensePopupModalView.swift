import Foundation
import UIKit
import ImageIO

protocol ExpensePopupDelegate: AnyObject {
    func popupChecked()
}

class ExpensePopupModalView: UIViewController {
    var dateText = ""
    var rateInfo: RateInfo?
    weak var delegate: ExpensePopupDelegate?
    var amount = 3000 // 임시값
    
    let customModal = UIView(frame: CGRect(x: 0, y: 0, width: 322, height: 400))
    
    let titleLabel: MPLabel = {
        let label = MPLabel()
        label.text = ""
        label.numberOfLines = 0
        label.font = UIFont.mpFont20B()
        return label
    }()
    
    let contentLabel: UnregisterTitleLabel = {
        let label = UnregisterTitleLabel()
        label.text = ""
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineSpacing = 2.0
        label.font = UIFont.mpFont16M()
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(UIColor.mpWhite, for: .normal)
        button.backgroundColor = UIColor.mpMainColor
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    // 모달 제목 바꾸는 함수
    func changeTitle(title: String) {
        titleLabel.text = title
        titleLabel.setNeedsLayout()
        titleLabel.layoutIfNeeded()
    }
    
    // 모달 내용 바꾸는 함수
    func changeContents(content: String) {
        contentLabel.text = content
        contentLabel.setNeedsLayout()
        contentLabel.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentCustomModal()
        setupBackground()
        setupView()
        
        // 정적 이미지를 설정합니다.
        imageView.image = UIImage(named: "img_popup_over") // 여기에 이미지 파일 이름을 넣습니다.
        
        completeButton.addTarget(self, action: #selector(complete), for: .touchUpInside)
    }
    
    @objc private func complete() {
        print("log: 팝업해제")
        dismiss(animated: true)
        delegate?.popupChecked()
    }
    
    func presentCustomModal() {
        customModal.backgroundColor = UIColor.mpWhite
        view.addSubview(customModal)
        customModal.center = view.center
    }
    
    private func setupBackground() {
        customModal.layer.cornerRadius = 25
        customModal.layer.masksToBounds = true
    }
    
    private func setupView() {
        customModal.addSubview(titleLabel)
        customModal.addSubview(contentLabel)
        customModal.addSubview(imageView)
        customModal.addSubview(completeButton)
        
        titleLabel.textAlignment = .center
        contentLabel.textAlignment = .center
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: customModal.topAnchor, constant: 35),
            titleLabel.centerXAnchor.constraint(equalTo: customModal.centerXAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            contentLabel.centerXAnchor.constraint(equalTo: customModal.centerXAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            imageView.centerXAnchor.constraint(equalTo: customModal.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 174),
            imageView.widthAnchor.constraint(equalToConstant: 174),
            
            completeButton.bottomAnchor.constraint(equalTo: customModal.bottomAnchor, constant: -15),
            completeButton.leadingAnchor.constraint(equalTo: customModal.leadingAnchor, constant: 15),
            completeButton.trailingAnchor.constraint(equalTo: customModal.trailingAnchor, constant: -15),
            completeButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }
}


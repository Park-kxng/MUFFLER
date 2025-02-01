//
//  ProfileViewController.swift
//  Money-Planner
//
//  Created by p_kxn_g on 2/2/24.
//

import Foundation
import UIKit

protocol ProfileViewDelegate : AnyObject{
    func profileNameChanged(_ userName : String, _ profileImage : String)
    
}
class ProfileViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CategoryIconSelectionDelegate {
    func didSelectCategoryIcon(_ icon: Int) {
        print("아이콘 설정 완료")
        if icon != 9 {
            selectedIcon = "add-0\(icon+1)"
        }else{
            selectedIcon = "add-\(icon+1)"
        }
        picButton.setImage(UIImage(named: selectedIcon), for: .normal)
    }
    let viewModel = LoginViewModel()
    
    private var UserName: String?
    var profileImage: UIImage?
    var selectedIcon : String = ""
    var initName : String = ""
    var initImg : String = ""
    weak var delegate: ProfileViewDelegate?
    private lazy var headerView = HeaderView(title: "프로필 설정")
    var currText : String = ""
    let picContainer : UIView = {
        let view = UIView()
        //view.backgroundColor = .red
        return view
    }()
    lazy var picButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: selectedIcon), for: .normal)
        button.layer.cornerRadius = 45
        button.layer.masksToBounds = true
        button.backgroundColor = .mpGypsumGray
        return button
    }()

    @objc 
    func editProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    let nameContainer : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mpGypsumGray
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false // Add this line
        return view
    }()
    let errorContainer : UIView = {
        let view = UIView()
        //view.backgroundColor = .red
        return view
    }()
    
    // 이름 수정 버튼
    lazy var nameEditButton: UIButton = {
        let button = UIButton()
        let arrowImage = UIImage(named: "btn_Edit_fill")?.withTintColor(.mpMidGray, renderingMode: .alwaysOriginal)
        button.setImage(arrowImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isUserInteractionEnabled = true  // 클릭 활성화
        button.addTarget(self, action: #selector(editName), for: .touchUpInside) //이름 수정 액션 추가
        return button
    }()

    @objc
    func editName(){
        print("이름을 수정할 수 있습니다")
        // 이름 수정 가능하게 변경
        nameTextField.isEnabled = true
        nameEditButton.isEnabled = false // 수정 버튼 클릭 막기
        let currTextSize = nameTextField.text?.count
        nameEditButton.setImage(nil, for: .normal)// 버튼 이미지 삭제
        if let textSize = currTextSize {
            nameEditButton.setTitle("\(textSize)/16", for: .normal)
        }
        nameEditButton.titleLabel?.font = .mpFont14B()
        nameEditButton.setTitleColor(.mpDarkGray, for: .normal)
    }
    private var completeButton = MainBottomBtn(title: "완료")
    private let nameTextField : UITextField = {
        let text = UITextField()
        text.layer.cornerRadius = 8
        text.layer.masksToBounds = true
        text.borderStyle = .none
        text.font = UIFont.mpFont20M()
        text.tintColor = UIColor.mpMainColor
        text.backgroundColor = .clear
        text.keyboardType = .default
        // 여백 추가
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: text.frame.height)) // 조절하고자 하는 여백 크기
        text.leftView = leftView
        text.leftViewMode = .always
        
        return text
    }()
 
    private let nameLabel : MPLabel = {
        let label = MPLabel()
        label.font = .mpFont14B()
        label.text = "닉네임"
        label.textColor = .mpGray
        return label
    }()
   
    
    init(name: String, imgName : String) {
        super.init(nibName: nil, bundle: nil)
        self.UserName = name
        self.selectedIcon = imgName
        // 비교하기 위하여 초기 사진 및 이름 저장
        self.initImg = imgName
        self.initName = name
        // 텍스트 필드에 세팅
        nameTextField.text = UserName
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        setupUI()
    }
    private func setupUI() {
        // 배경색상 추가
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "mpWhite")
        view.backgroundColor = .systemBackground
        
        // 헤더
        setupHeader()
        
        // 완료 버튼 추가
        setupCompleteButton()
        // 프로필, 이름 설정
        setupPic()
        setupNameLabel()
        setupTextField()

        
        nameTextField.delegate = self // Make sure to set the delegate
        picButton.addTarget( self, action: #selector(selectIcon), for: .touchUpInside) //이름 수정 가능하게
        hideKeyboardWhenTappedAround()
    }
    
    // 세팅 : 헤더
    private func setupHeader(){
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60)
            
        ])
        
        headerView.addBackButtonTarget(target: self, action: #selector(previousScreen), for: .touchUpInside)
    }
    @objc private func previousScreen(){
        dismiss(animated: true)
    }
    private func setupPic(){
        // 컨테이너 추가
        view.addSubview(picContainer)
        picContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 48),
            picContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picContainer.heightAnchor.constraint(equalToConstant: 90),
            picContainer.widthAnchor.constraint(equalToConstant: 90)
        ])
        // 버튼 추가
        picContainer.addSubview(picButton)
           picButton.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               picButton.topAnchor.constraint(equalTo: picContainer.topAnchor),
               picButton.leadingAnchor.constraint(equalTo: picContainer.leadingAnchor),
               picButton.trailingAnchor.constraint(equalTo: picContainer.trailingAnchor),
               picButton.bottomAnchor.constraint(equalTo: picContainer.bottomAnchor)
           ])
        let plus: UIView = {
                 let view = UIView()
                 view.backgroundColor = .clear
                 view.layer.cornerRadius = 10
                 view.layer.masksToBounds = true
                 return view
             }()
        let plusImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "plus.circle.fill")?
                .withTintColor(.mpGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium))
            imageView.contentMode = .scaleAspectFit
                       return imageView
                   }()

         view.addSubview(plus)
         plus.addSubview(plusImageView)

         plus.translatesAutoresizingMaskIntoConstraints = false
         plusImageView.translatesAutoresizingMaskIntoConstraints = false
 
         NSLayoutConstraint.activate([
             plus.heightAnchor.constraint(equalToConstant: 20),
             plus.widthAnchor.constraint(equalToConstant: 20),
             plus.trailingAnchor.constraint(equalTo: picContainer.trailingAnchor),
             plus.bottomAnchor.constraint(equalTo: picContainer.bottomAnchor),
         ])
 
         NSLayoutConstraint.activate([
             plusImageView.topAnchor.constraint(equalTo: plus.topAnchor),
             plusImageView.leadingAnchor.constraint(equalTo: plus.leadingAnchor),
             plusImageView.trailingAnchor.constraint(equalTo: plus.trailingAnchor),
             plusImageView.bottomAnchor.constraint(equalTo: plus.bottomAnchor),
         ])

        
    }
    private func setupNameLabel(){
        //4
        //38
        // 높이 23
        // 컨테이터
        
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: picContainer.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        

    }
    private func setupTextField(){
        view.addSubview(nameContainer)
        NSLayoutConstraint.activate([
            
            nameContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            nameContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameContainer.heightAnchor.constraint(equalToConstant: 64)
        ])
        // 텍스트 필드
                nameContainer.addSubview(nameTextField)
                
                // 텍스트 필드
                NSLayoutConstraint.activate([
                    nameTextField.topAnchor.constraint(equalTo: nameContainer.topAnchor),
                    nameTextField.bottomAnchor.constraint(equalTo: nameContainer.bottomAnchor),
                    nameTextField.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor),
                    nameTextField.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor),
                ])
                nameTextField.translatesAutoresizingMaskIntoConstraints = false
                nameTextField.isEnabled = false // 수정가능

        
        // 버튼 컨테이너
        let buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        buttonContainerView.backgroundColor = .clear
        nameContainer.addSubview(buttonContainerView)
        
        NSLayoutConstraint.activate([
            buttonContainerView.widthAnchor.constraint(equalToConstant: 40),
                buttonContainerView.heightAnchor.constraint(equalToConstant: 40),
                buttonContainerView.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),
                buttonContainerView.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -16)
              
    
        
        ])
        buttonContainerView.addSubview(nameEditButton)
        // 클릭 되게 하려고.... 시도 중
        buttonContainerView.isUserInteractionEnabled = true
//        self.view.bringSubviewToFront(nameEditButton)
//        nameEditButton.isUserInteractionEnabled = true
//        buttonContainerView.layer.zPosition = 999
        
        NSLayoutConstraint.activate([
            nameEditButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            nameEditButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            nameEditButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            nameEditButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor)
        ])

    }
 
    // 세팅 : 완료 버튼
    private func setupCompleteButton(){
        completeButton.isEnabled = true // 버튼 활성화
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)

    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        currText = newText
        checkAndEnableCompleteButton()
        let textSize = newText.count
        if textSize > 16 {
            
            // Your existing code to handle the error (e.g., update UI elements)
            textField.layer.borderColor = UIColor.mpRed.cgColor
            textField.layer.borderWidth = 1.0  // Set an appropriate border width
            nameEditButton.setTitleColor(.mpRed, for: .normal)

            return false
        } else {
            nameEditButton.setTitle("\(textSize)/16", for: .normal)
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.borderWidth = 0.0
            nameEditButton.setTitleColor(.mpDarkGray, for: .normal)
            return true
        }
    }
    @objc
    private func selectIcon(){
        // 프로필 설정 모달
        let iconSelectionVC = CategoryIconSelectionViewController()
        iconSelectionVC.delegate = self
        present(iconSelectionVC, animated: true)
    }
    
    // 완료 버튼 활성화 확인
    private func checkAndEnableCompleteButton() {
        if currText != ""  && currText.count < 16{
            completeButton.isEnabled = true
        }else{
            completeButton.isEnabled = false
        }

    }
    
    @objc
    private func completeButtonTapped(){
        print("프로필 설정이 완료되었습니다..")
        if currText != "" || selectedIcon != initImg{
            viewModel.join(name: currText, img: selectedIcon) { success in
                if success{
                    print("결과 : 프로필 설정 완료")
                    // 프로필 저장
                    if self.currText != ""{
                        // 텍스트 필드를 수정했다는 의미
                        self.currText = self.nameTextField.text ?? ""
                    }
                    else{
                        // 텍스트 필드는 수정 안했음
                        self.currText = self.initName
                    }
                    UserDefaults.standard.set(self.currText, forKey: "name")
                    UserDefaults.standard.set(self.selectedIcon, forKey: "profileImg")
                    self.delegate?.profileNameChanged(self.currText, self.selectedIcon)
                    self.dismiss(animated: true, completion: nil) // 뒤로 가기

                }else{
                    print("결과 : 프로필 설정 실패")
                }
            }
        }
        dismiss(animated: true, completion: nil) // 뒤로 가기

       
        
    }
}
// 키보드 숨기기
extension ProfileViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

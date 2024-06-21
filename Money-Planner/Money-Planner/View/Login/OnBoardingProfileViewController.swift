//
//  OnBoardingProfileViewController.swift
//  Money-Planner
//
//  Created by p_kxn_g on 4/4/24.
//

import Foundation
import UIKit

class OnBoardingProfileViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CategoryIconSelectionDelegate {
    func didSelectCategoryIcon(_ icon: Int) {
        print("아이콘 설정 완료")
        
        if icon != 9 {
            selectedIcon = "add-0\(icon+1)"
        }else{
            selectedIcon = "add-\(icon+1)"
        }
        picButton.setImage(UIImage(named: selectedIcon), for: .normal)
    }
    
    private var UserName: String = ""
    var profileImage: UIImage?
    var selectedIcon : String = "add-05"
    weak var delegate: ProfileViewDelegate?
    private lazy var headerView = HeaderView(title: "")
    var currText : String = ""
    let viewModel = LoginViewModel()
    
    private let titleLabel : UnregisterTitleLabel = {
        let label = UnregisterTitleLabel()
        label.font = .mpFont26B()
        label.text = "프로필을 입력해주세요"
        label.numberOfLines = 1
        label.textColor = .mpBlack
        return label
    }()
    
    let picContainer : UIView = {
        let view = UIView()
        //view.backgroundColor = .red
        return view
    }()
    let picButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add-05"), for: .normal)
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
        let currTextSize = nameTextField.text?.count
        if let textSize = currTextSize {
            button.setTitle("\(textSize)/16", for: .normal)
        }
        button.titleLabel?.font = .mpFont14B()
        button.setTitleColor(.mpDarkGray, for: .normal)
       
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false  // 클릭 비활성화
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
        text.isUserInteractionEnabled = true
        text.isEnabled = true
        
        return text
    }()
    
    private let nameLabel : MPLabel = {
        let label = MPLabel()
        label.font = .mpFont14B()
        label.text = "이름"
        label.textColor = .mpGray
        return label
    }()

    
    init() {
            super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        setupUI()
    }
    private func setupUI() {
        super.viewDidLoad()
        
        // 배경색상 추가
        view.backgroundColor = UIColor(named: "mpWhite")
        view.backgroundColor = .systemBackground

        // 제목
        setupTitleLabel()
        // 완료 버튼 추가
        setupCompleteButton()
        completeButton.isEnabled = false
        
        // 프로필, 텍스트필드
        setupPic()
        setupNameLabel()
        setupTextField()

        nameTextField.delegate = self // Make sure to set the delegate
        // 키보드 숨김
        hideKeyboardWhenTappedAround()

    }
    
 
    
    private func setupTitleLabel(){
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
        ])
    }
    
    @objc private func previousScreen(){
        dismiss(animated: true)
    }
    private func setupPic(){
        // 컨테이너 추가
        view.addSubview(picContainer)
        picContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
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
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
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
        picButton.addTarget( self, action: #selector(selectIcon), for: .touchUpInside)
    }
    
    private func setupNameLabel(){

        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: picContainer.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        

    }
    private func setupTextField() {
        view.addSubview(nameContainer)
        NSLayoutConstraint.activate([
            nameContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameContainer.heightAnchor.constraint(equalToConstant: 64) // Set a fixed height
        ])
        
        
        
        // 버튼 컨테이너
        let buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        nameContainer.addSubview(buttonContainerView)
        
        
        NSLayoutConstraint.activate([
            buttonContainerView.widthAnchor.constraint(equalToConstant: 40),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 40),
            buttonContainerView.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),
            buttonContainerView.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -16)
        ])
        
        buttonContainerView.addSubview(nameEditButton)
        
        NSLayoutConstraint.activate([
            nameEditButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            nameEditButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            nameEditButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            nameEditButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor)
        ])
        
        // Add the text field to the nameContainer
        nameContainer.addSubview(nameTextField)
        nameTextField.isEnabled = true
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: nameContainer.topAnchor),
            nameTextField.bottomAnchor.constraint(equalTo: nameContainer.bottomAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor)
        ])
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
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
        let textSize = newText.count
        currText = newText
        print(currText)
        // 완료 버튼 활성화 확인
        checkAndEnableCompleteButton()
        
        if textSize > 16 {
            
            // Your existing code to handle the error (e.g., update UI elements)
            nameContainer.layer.borderColor = UIColor.mpRed.cgColor
            nameContainer.layer.borderWidth = 1.0  // Set an appropriate border width
            nameEditButton.setTitleColor(.mpRed, for: .normal)

            return false
        } else {
            nameEditButton.setTitle("\(textSize)/16", for: .normal)
            nameContainer.layer.borderColor = UIColor.clear.cgColor
            nameContainer.layer.borderWidth = 0.0
            nameEditButton.setTitleColor(.mpDarkGray, for: .normal)
            return true
        }
    }
    
    
    @objc
    private func completeButtonTapped(){
        print("완료 버튼 클릭 > 프로필 설정 시도")
        if let curr_name = nameTextField.text {
            viewModel.join(name: curr_name, img: selectedIcon) { success in
                if success{
                    print("결과 : 프로필 설정 완료")
                    
                    UserDefaults.standard.set(self.nameTextField.text, forKey: "name")
                    UserDefaults.standard.set(self.selectedIcon, forKey: "profileImg")


                    // 다음 온보딩 화면으로 이동하기
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.moveToOnBoardingNextStep()
                    }

                }else{
                    print("결과 : 프로필 설정 실패")
                }
            }
            
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
}
// 키보드 숨기기
extension OnBoardingProfileViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(OnBoardingProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

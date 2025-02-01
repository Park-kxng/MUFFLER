//
//  EditGoalViewController.swift
//  Money-Planner
//
//  Created by Jini on 2024/01/26.
//

import Foundation
import UIKit
import RxSwift

class EditGoalViewController : UIViewController {
    
//    let amount : Int64
    let goalId : Int64
//    let startDate : String
//    let endDate : String
    
    let viewModel = GoalEditViewModel.shared
    var disposeBag = DisposeBag()
    
    init(goalId: Int64) {//, startDate: String, endDate: String, amount: Int64
        self.goalId = goalId
//        self.startDate = startDate
//        self.endDate = endDate
//        self.amount = amount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let contentScrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.mpWhite
        
        return view
    }()
    
    let backgroundView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 38
        view.backgroundColor = UIColor(hexCode: "#DFF2F1")
        
        return view
    }()
    
    let emojiTextfield = EmojiTextField()
    
    let goalNameLabel = SmallDescriptionView(text: "목표 이름", alignToCenter: false)
    let goalNameTextfield = MainTextField(placeholder: "", iconName: "icon_Paper")
    let characterCountLabel = UILabel()
    
    let goalPeriodLabel = SmallDescriptionView(text: "목표 기간", alignToCenter: false)
    let goalPeriodTextfield = LockedTextField(placeholder: "", iconName: "icon_date")
    
    let dateLabel = UILabel()
    
    let totalPeriodLabel = UILabel()
    
    let goalBudgetLabel = SmallDescriptionView(text: "목표 예산", alignToCenter: false)
    let goalBudgetTextfield = LockedTextField(placeholder: "", iconName: "icon_Wallet")
    
    let numAmount = UILabel()
    let charAmount = UILabel()
    let wonLabel = UILabel()
    let moreLabel = SmallDescriptionView(text: "자세히", alignToCenter: false)
    let editByCategory = TextImageButton()
    let editByDate = TextImageButton()
    
    let confirmBtn = MainBottomBtn(title: "저장")
    
    override func viewDidLoad(){
        view.backgroundColor = UIColor.mpWhite
        
        hideKeyboard()
        
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            
            contentView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 800)
        ])
        
        setupNavigationBar()
        setupImageEdit()
        setupNameEdit()
        setupPeriodEdit()
        setupBudgetEdit()
        setupMore()
        setupNextButton()
        
        emojiTextfield.delegate = self
        goalNameTextfield.delegate = self
        
        viewModel.fetchGoal(goalId: String(goalId))
        
        // GoalDetail 데이터 수신
        viewModel.goalDetailRelay
            .subscribe(onNext: { [weak self] goalDetail in
                self?.configureNameEdit(title: goalDetail.title)
                self?.configurePeriodEdit(startDate: goalDetail.startDate, endDate: goalDetail.endDate)
                self?.configureBudgetEdit(totalAmount: goalDetail.totalBudget)
                self?.configureEmoji(emoji: goalDetail.icon)
            })
            .disposed(by: disposeBag)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchGoal(goalId: String(goalId))
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        self.view.endEditing(true) // 키보드를 숨기는 메서드 호출
//    }
    
    func validateFields() {
        // Ensure the emojiTextField has a single emoji and the goalNameTextField is not empty.
        let isEmojiValid = emojiTextfield.text?.count == 1
        let isTitleValid = !(goalNameTextfield.text?.isEmpty ?? true) && goalNameTextfield.text!.count <= 15
        
        // Enable the next button if both conditions are met.
        confirmBtn.isEnabled = isEmojiValid && isTitleValid
    }
    
    func hideKeyboard() {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
    }
        
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension EditGoalViewController : goalDeleteModalDelegate {
    
    func deleteGoal() {
        // 삭제 api 연결
        viewModel.deleteGoalByGoalID(goalId: self.goalId)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension EditGoalViewController : UIScrollViewDelegate, UITextFieldDelegate {
    
    func setupNavigationBar() {
        
        let deleteButton : UIBarButtonItem = {
            let button = UIButton(type: .system)
            button.setTitle("삭제", for: .normal)
            button.tintColor = UIColor.mpRed
            button.titleLabel?.font = UIFont.mpFont18M()
            button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
            
            return UIBarButtonItem(customView: button)
        }()
        
        self.navigationItem.title = "소비목표 수정"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mpBlack, NSAttributedString.Key.font: UIFont.mpFont18B()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        //self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = deleteButton
        
    }
    
    @objc private func deleteButtonTapped() {
        print("삭제버튼 클릭")
        presentCustomModal()
    }
    // 목표 삭제 모달
    func presentCustomModal() {
        let customModalVC = goalDeleteModalView(goalName: goalNameTextfield.text!)
        customModalVC.modalPresentationStyle = .overFullScreen
        customModalVC.modalTransitionStyle = .crossDissolve
        customModalVC.delegate = self
        present(customModalVC, animated: true, completion: nil)
        customModalVC.deleteButton.addTarget(self, action: #selector(deleteAndReturnByCustomModal), for: .touchUpInside)
    }
    // 목표 삭제 진행 함수
    @objc private func deleteAndReturnByCustomModal() {
        // 목표 데이터 삭제 진행
        
        dismiss(animated: true, completion: nil)
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
     }
    
    func configureEmoji(emoji : String){
        emojiTextfield.text = emoji
    }
    
    func setupImageEdit() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        emojiTextfield.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundView)
        contentView.addSubview(emojiTextfield)
        
        emojiTextfield.font = UIFont.systemFont(ofSize: 40)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            backgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 76),
            backgroundView.widthAnchor.constraint(equalToConstant: 76),
            
            emojiTextfield.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            emojiTextfield.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            emojiTextfield.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        let addButtonImageView = UIImageView(image: UIImage(named: "btn_Add_icon"))
        addButtonImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(addButtonImageView)
        
        NSLayoutConstraint.activate([
            addButtonImageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: 1),
            addButtonImageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -2),
            addButtonImageView.widthAnchor.constraint(equalToConstant: 24),
            addButtonImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        emojiTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func configureNameEdit(title : String){
        goalNameTextfield.text = title
        characterCountLabel.text = "\(title.count)" + "/15"
    }
    
    func setupNameEdit() {
        goalNameLabel.translatesAutoresizingMaskIntoConstraints = false
        goalNameTextfield.translatesAutoresizingMaskIntoConstraints = false
        characterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(goalNameLabel)
        contentView.addSubview(goalNameTextfield)
        contentView.addSubview(characterCountLabel)
        
        characterCountLabel.font = UIFont.mpFont14M()
        characterCountLabel.textColor = UIColor.mpDarkGray
        characterCountLabel.textAlignment = .right
        
        let paddingContainer = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 0))
        goalNameTextfield.rightView = paddingContainer
        goalNameTextfield.rightViewMode = .always
        
        NSLayoutConstraint.activate([
            goalNameLabel.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 26),
            goalNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            goalNameLabel.heightAnchor.constraint(equalToConstant: 18),
            
            goalNameTextfield.topAnchor.constraint(equalTo: goalNameLabel.bottomAnchor, constant: 8),
            goalNameTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            goalNameTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            goalNameTextfield.heightAnchor.constraint(equalToConstant: 64),
            
            characterCountLabel.centerYAnchor.constraint(equalTo: goalNameTextfield.centerYAnchor),
            characterCountLabel.trailingAnchor.constraint(equalTo: goalNameTextfield.trailingAnchor, constant: -20)
        ])
        
        goalNameTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        validateFields()
        if textField == goalNameTextfield {
            let textCount = goalNameTextfield.text?.count ?? 0
            characterCountLabel.text = "\(textCount)/15"
        }
    }
    
    func configurePeriodEdit(startDate : String, endDate : String){
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일" // Custom format for "month day"
        formatter.locale = Locale(identifier: "ko_KR") // Korean locale to ensure month names are in Korean

        let startDateString = formatter.string(from: startDate.toDate!)
        let endDateString = formatter.string(from: endDate.toDate!)
        dateLabel.text = "\(startDateString) - \(endDateString)"
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate.toDate!, to: endDate.toDate!)
        if let day = components.day {
            totalPeriodLabel.text = (day+1) % 7 == 0 ? "\((day+1) / 7)주" : "\(day+1)일"
        }
    }
    
    func setupPeriodEdit() {
        goalPeriodLabel.translatesAutoresizingMaskIntoConstraints = false
        goalPeriodTextfield.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPeriodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(goalPeriodLabel)
        contentView.addSubview(goalPeriodTextfield)
        contentView.addSubview(dateLabel)
        contentView.addSubview(totalPeriodLabel)
        
        
        dateLabel.font = UIFont.mpFont20M()
        dateLabel.textColor = UIColor.mpGray
    
        totalPeriodLabel.font = UIFont.mpFont20M()
        totalPeriodLabel.textColor = UIColor.mpMainColor
        totalPeriodLabel.textAlignment = .right
        
        NSLayoutConstraint.activate([
            goalPeriodLabel.topAnchor.constraint(equalTo: goalNameTextfield.bottomAnchor, constant: 26),
            goalPeriodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            goalPeriodLabel.heightAnchor.constraint(equalToConstant: 18),
            
            goalPeriodTextfield.topAnchor.constraint(equalTo: goalPeriodLabel.bottomAnchor, constant: 8),
            goalPeriodTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            goalPeriodTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            goalPeriodTextfield.heightAnchor.constraint(equalToConstant: 64),
            
            dateLabel.centerYAnchor.constraint(equalTo: goalPeriodTextfield.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: goalPeriodTextfield.leadingAnchor, constant: 60),
            
            totalPeriodLabel.centerYAnchor.constraint(equalTo: goalPeriodTextfield.centerYAnchor),
            totalPeriodLabel.trailingAnchor.constraint(equalTo: goalPeriodTextfield.trailingAnchor, constant: -20)
        ])
    }
    
    func setComma(cash: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: cash)) ?? ""
    }
    
    func numberToKorean(_ number: Int64) -> String {
        let unitLarge = ["", "만", "억", "조"]
        
        var result = ""
        var num = number
        var unitIndex = 0
        
        while num > 0 {
            let segment = num % 10000
            if segment != 0 {
                result = "\((segment))\(unitLarge[unitIndex]) \(result)"
            }
            num /= 10000
            unitIndex += 1
        }
        
        return result.isEmpty ? "0" : result
    }
    
    func configureBudgetEdit(totalAmount : Int64){
        numAmount.text = setComma(cash: totalAmount)
        charAmount.text = numberToKorean(totalAmount)
    }
    
    func setupBudgetEdit() {
        goalBudgetLabel.translatesAutoresizingMaskIntoConstraints = false
        goalBudgetTextfield.translatesAutoresizingMaskIntoConstraints = false
        wonLabel.translatesAutoresizingMaskIntoConstraints = false
        numAmount.translatesAutoresizingMaskIntoConstraints = false
        charAmount.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(goalBudgetLabel)
        contentView.addSubview(goalBudgetTextfield)
        contentView.addSubview(wonLabel)
        contentView.addSubview(numAmount)
        contentView.addSubview(charAmount)
        
        numAmount.text = "140,000"
        numAmount.font = UIFont.mpFont20M()
        numAmount.textColor = UIColor.mpGray
        
        charAmount.text = "14만"
        charAmount.font = UIFont.mpFont14M()
        charAmount.textColor = UIColor(hexCode: "#C4C4C4")
        
        wonLabel.text = "원"
        wonLabel.font = UIFont.mpFont20M()
        wonLabel.textColor = UIColor.mpGray
        wonLabel.textAlignment = .right
        
        NSLayoutConstraint.activate([
            goalBudgetLabel.topAnchor.constraint(equalTo: goalPeriodTextfield.bottomAnchor, constant: 26),
            goalBudgetLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            goalBudgetLabel.heightAnchor.constraint(equalToConstant: 18),
            
            goalBudgetTextfield.topAnchor.constraint(equalTo: goalBudgetLabel.bottomAnchor, constant: 8),
            goalBudgetTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            goalBudgetTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            goalBudgetTextfield.heightAnchor.constraint(equalToConstant: 64),
            
            numAmount.centerYAnchor.constraint(equalTo: goalBudgetTextfield.centerYAnchor),
            numAmount.leadingAnchor.constraint(equalTo: goalBudgetTextfield.leadingAnchor, constant: 60),
            
            charAmount.centerYAnchor.constraint(equalTo: goalBudgetTextfield.centerYAnchor),
            charAmount.leadingAnchor.constraint(equalTo: numAmount.trailingAnchor, constant: 5),
            
            wonLabel.centerYAnchor.constraint(equalTo: goalBudgetTextfield.centerYAnchor),
            wonLabel.trailingAnchor.constraint(equalTo: goalBudgetTextfield.trailingAnchor, constant: -20)
        ])
    }
    
    func setupMore() {
        let seperateView = UIView()
        seperateView.backgroundColor = UIColor.mpGypsumGray
        seperateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seperateView)
        
        NSLayoutConstraint.activate([
            seperateView.topAnchor.constraint(equalTo: goalBudgetTextfield.bottomAnchor, constant: 40),
            seperateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            seperateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            seperateView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        editByCategory.text = "카테고리별 목표 수정"
        editByCategory.image = UIImage(named: "btn_arrow_small-black")
        editByCategory.addTarget(self, action: #selector(categoryGoalEditButtonTapped), for: .touchUpInside)
        
        editByDate.text = "날짜별 목표 수정"
        editByDate.image = UIImage(named: "btn_arrow_small-black")
        editByDate.addTarget(self, action: #selector(dailyGoalEditButtonTapped), for: .touchUpInside)
    
        contentView.addSubview(moreLabel)
        contentView.addSubview(editByCategory)
        contentView.addSubview(editByDate)
        
        moreLabel.translatesAutoresizingMaskIntoConstraints = false
        editByCategory.translatesAutoresizingMaskIntoConstraints = false
        editByDate.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            moreLabel.topAnchor.constraint(equalTo: seperateView.bottomAnchor, constant: 40),
            moreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            moreLabel.heightAnchor.constraint(equalToConstant: 18),
        
            editByCategory.topAnchor.constraint(equalTo: moreLabel.bottomAnchor, constant: 20),
            editByCategory.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editByCategory.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editByCategory.heightAnchor.constraint(equalToConstant: 30),
            
            editByDate.topAnchor.constraint(equalTo: editByCategory.bottomAnchor, constant: 30),
            editByDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editByDate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editByDate.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func categoryGoalEditButtonTapped() {
        print("카테고리 목표 수정")
        let vc = EditGoalCategoryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func dailyGoalEditButtonTapped() {
        print("버튼눌림")
        let vc = EditGoalDailyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupNextButton(){
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        confirmBtn.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        view.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            confirmBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            confirmBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            confirmBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            confirmBtn.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    @objc func confirmButtonTapped(){
        viewModel.updateGoalTitleAndIcon(goalId: String(goalId), newTitle: goalNameTextfield.text!, newIcon: emojiTextfield.text!)
        navigationController?.popViewController(animated: true)
    }
    
    func createListLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.mpFont20M()
        label.textColor = UIColor.mpBlack
        return label
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == goalNameTextfield {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            return updatedText.count <= 15
        }

        return true
    }
}

class SmallDescriptionView: MPLabel {

    init(text: String, alignToCenter: Bool) {
        super.init(frame: .zero)
        self.text = text
        self.textAlignment = alignToCenter ? .center : .left
        self.textColor = UIColor.mpGray
        self.font = UIFont.mpFont14B()
        self.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LockedTextField: UITextField {
    let systemIconImageView = UIImageView()

    init(placeholder: String, iconName: String, keyboardType: UIKeyboardType = .default,frame:CGRect = .zero) {
        super.init(frame: frame)
        setupTextField(placeholder: placeholder, iconName: iconName,keyboardType: keyboardType)
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextField(placeholder: String, iconName: String,  keyboardType: UIKeyboardType) {
        self.placeholder = placeholder

        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderColor = UIColor.mpLightGray.cgColor
        layer.borderWidth = 1.0
        textColor = UIColor.mpGray
        font = UIFont.mpFont20M()
        backgroundColor = .mpWhite
        self.keyboardType = keyboardType
        
        // 텍스트 필드에 시스템 아이콘 이미지 추가
        systemIconImageView.image = UIImage(named: iconName)
        systemIconImageView.tintColor = UIColor.mpMainColor// 시스템 아이콘 이미지 색상 설정
        //systemIconImageView.contentMode = .scaleAspectFit

        // 아이콘 이미지 크기와 여백 설정
        let iconSize: CGFloat = 25
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: iconSize, height: iconSize))
        iconContainerView.addSubview(systemIconImageView)

        systemIconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            systemIconImageView.leadingAnchor.constraint(equalTo: iconContainerView.leadingAnchor, constant: 20),
            systemIconImageView.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant:-16),
            systemIconImageView.topAnchor.constraint(equalTo: iconContainerView.topAnchor),
            systemIconImageView.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor)
        ])

        leftView = iconContainerView
        leftViewMode = .always
    
    }
    
    
}

class TextImageButton: UIButton {
    let textLabel: MPLabel = {
        let label = MPLabel()
        label.textAlignment = .left
        label.font = UIFont.mpFont20M()
        label.textColor = UIColor.mpBlack
        
        return label
    }()
    
    let arrowImage: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    var image: UIImage? {
        didSet {
            arrowImage.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(textLabel)
        addSubview(arrowImage)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            arrowImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            arrowImage.widthAnchor.constraint(equalToConstant: 24),
            arrowImage.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}

//class EmojiTextField: UITextField {
//    override var textInputContextIdentifier: String? { "" }
//    
//    override var textInputMode: UITextInputMode? {
//        for mode in UITextInputMode.activeInputModes {
//            if mode.primaryLanguage == "emoji" {
//                return mode
//            }
//        }
//        return nil
//    }
//    
//    // 백스페이스 허용
//    override func deleteBackward() {
//        super.deleteBackward()
//    }
//    
//    // 커서 숨기기
//    override func caretRect(for position: UITextPosition) -> CGRect {
//        return .zero
//    }
//}

class EmojiTextField: UITextField, UITextFieldDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self // 텍스트 필드의 델리게이트로 자기 자신을 지정합니다.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    // TextField Delegate 메서드를 사용하여 문자 수 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 현재 텍스트를 가져옵니다.
        let currentText = textField.text ?? ""
        
        // 예정된 텍스트 변경으로 인해 업데이트 될 텍스트를 가져옵니다.
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 새로운 텍스트의 길이가 1자 이하인지 확인하고, 그에 따라 true 또는 false를 반환합니다.
        return updatedText.count <= 1
    }
    
    // 나머지 EmojiTextField 구현
    override var textInputContextIdentifier: String? { "" }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
    
    override func deleteBackward() {
        super.deleteBackward()
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
}

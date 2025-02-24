//
//  MakeGoalViewController.swift
//  Money-Planner
//
//  Created by 유철민 on 1/6/24.
//

import Foundation
import UIKit
import Moya

// 도전할 소비 목표의 기간을 선택해주세요
extension GoalPeriodViewController: PeriodSelectionDelegate {
    
    func cancelFilter1() {
       //여기선 필요 없음.
    }
    
    func periodSelectionDidSelectDates(startDate: Date, endDate: Date) {
        periodBtn.setPeriod(startDate: startDate, endDate: endDate)
        btmbtn.isEnabled = true // btmBtn의 이름은 실제 버튼 변수명에 따라 달라질 수 있음
        print("보여지는 period 변경 실행")
    }
}

extension GoalPeriodViewController: FoundPreviousConsumeRecordModalDelegate {
    func modalGoToGoalAmountVC(canRestore : Bool, restore : Bool?) {
        goToGoalAmountVC()
        goalCreationManager.restoration(canRestore: canRestore, restore: restore)
    }
}

class GoalPeriodViewController : UIViewController, UINavigationControllerDelegate {
    
    private var descriptionView : DescriptionView = DescriptionView(text: "도전할 소비 목표의 기간을 선택해주세요", alignToCenter: false)
    private lazy var periodBtn = PeriodButton()
    private lazy var btmbtn : MainBottomBtn = MainBottomBtn(title: "다음")
    
    private let goalCreationManager = GoalCreationManager.shared //목표 생성용
    private let viewModel = GoalPeriodViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
     
        setupDescriptionView()
        setupPeriodBtn()
        setUpBtmBtn()
    }

    override func viewDidAppear(_ animated: Bool) {
        viewModel.fetchPreviousGoals()
        super.viewDidAppear(animated)
    }
    
    @objc func btmButtonTapped() {
//        goToGoalAmountVC()
        //이전 소비내역 발견, 모달 띄우기.
        
        findOutPreviousConsumeRecord { [self] canRestore in
            if canRestore {
                let modal = FoundPreviousConsumeRecordModal(startDate: periodBtn.startDate, endDate: periodBtn.endDate)
                modal.delegate = self
                self.present(modal, animated: true)
            } else {
                goalCreationManager.restoration(canRestore: false, restore: false)
                goToGoalAmountVC()
            }
        }
    }
    
    func goToGoalAmountVC(){
        print("목표 금액 등록 화면으로 이동")
        let goalTotalAmountVC = GoalTotalAmountViewController()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // goalCreationManager에 목표기간의 처음과 시작을 저장합니다
        let startDate = dateFormatter.string(from: periodBtn.startDate)
        goalCreationManager.startDate = startDate
        
        let endDate = dateFormatter.string(from: periodBtn.endDate)
        goalCreationManager.endDate = endDate
        

        navigationController?.pushViewController(goalTotalAmountVC, animated: true)
    }
    
    @objc private func backButtonTapped() {
        // 뒤로 가기 기능 구현
        goalCreationManager.startDate = nil
        goalCreationManager.endDate = nil
        navigationController?.popViewController(animated: true)
    }
    
    private func setupDescriptionView() {
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionView)
        
        NSLayoutConstraint.activate([
            descriptionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            descriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupPeriodBtn(){
        periodBtn.translatesAutoresizingMaskIntoConstraints = false
        periodBtn.addTarget(self, action: #selector(periodBtnTapped), for: .touchUpInside)
        view.addSubview(periodBtn)
        NSLayoutConstraint.activate([
            periodBtn.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 30),
            periodBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            periodBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            periodBtn.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    @objc private func periodBtnTapped() {
        let modal = PeriodCalendarModal()
        modal.delegate = self
        present(modal, animated: true, completion: nil)
    }


    private func setUpBtmBtn(){
        btmbtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btmbtn)
        NSLayoutConstraint.activate([
            btmbtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            btmbtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            btmbtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            btmbtn.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        btmbtn.addTarget(self, action: #selector(btmButtonTapped), for: .touchUpInside)
        btmbtn.isEnabled = false
    }
    
    //다음 버튼을 눌렀을때,
    func findOutPreviousConsumeRecord(completion: @escaping (Bool) -> Void) {
        let startDate = periodBtn.startDate
        let endDate = periodBtn.endDate
        viewModel.fetchCanRestore(startDate: startDate.toString(format: "yyyy-MM-dd"), endDate: endDate.toString(format: "yyyy-MM-dd")) { [weak self] canRestore in
            DispatchQueue.main.async {
                print("period 설정 끝. 부활 여부 알려주기 : \(canRestore)")
                completion(canRestore)
            }
        }
    }
    
}

class PeriodButton: UIButton {
    
    let iconImageView = UIImageView()
    let periodLabel = MPLabel()
    let spanLabel = MPLabel()
    var startDate = Date.todayAtMidnight
    var endDate = Date.todayAtMidnight
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSelf()
        setupIconImageView()
        setupSpanLabelField()
        setupPeriodLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSelf(){
        self.backgroundColor = .mpGypsumGray
        self.layer.cornerRadius = 10
    }
    
    private func setupIconImageView() {
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "calendar")
        iconImageView.tintColor = .mpGray
        self.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupPeriodLabel() {
        periodLabel.translatesAutoresizingMaskIntoConstraints = false
        periodLabel.text = "목표 기간 설정하기"
        self.addSubview(periodLabel)
        
        periodLabel.textColor = UIColor.mpGray
        periodLabel.textAlignment = .left
        
        NSLayoutConstraint.activate([
            periodLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            periodLabel.trailingAnchor.constraint(equalTo: spanLabel.trailingAnchor, constant: -20),
            periodLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            periodLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupSpanLabelField() {
        spanLabel.translatesAutoresizingMaskIntoConstraints = false
        spanLabel.text = ""
        self.addSubview(spanLabel)
        
        spanLabel.textColor = .mpMainColor
        
        NSLayoutConstraint.activate([
            spanLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            spanLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            spanLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            spanLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    func setPeriod(startDate: Date, endDate: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일" // Custom format for "month day"
        formatter.locale = Locale(identifier: "ko_KR") // Korean locale to ensure month names are in Korean

        let startDateString = formatter.string(from: startDate)
        let endDateString = formatter.string(from: endDate)
        periodLabel.text = "\(startDateString) - \(endDateString)"
        periodLabel.textColor = .mpBlack
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        if let day = components.day {
            spanLabel.text = (day+1) % 7 == 0 ? "\((day+1) / 7)주" : "\(day+1)일"
        }
        
        self.startDate = startDate
        self.endDate = endDate
    }
    
}

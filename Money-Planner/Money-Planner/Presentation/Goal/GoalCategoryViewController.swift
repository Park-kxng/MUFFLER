//
//  GoalCategoryViewController.swift
//  Money-Planner
//
//  Created by 유철민 on 1/12/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension GoalCategoryViewController: CategorySelectionDelegate{
    
    func didSelectCategory(id: Int64, category: String, iconName: String) {
        // 선택된 카테고리 정보를 업데이트
        if let index = selectedIndexPath?.section {
            // data 배열에 선택된 카테고리 정보 업데이트
            if index < data.count {
                data[index].categoryId = id
                data[index].categoryName = category
                data[index].categoryIcon = iconName
            } else {
                // 선택된 섹션 인덱스가 data 배열의 크기보다 큰 경우, 새로운 카테고리 정보를 추가
                let newCategory = GoalCategory(categoryName: category, categoryIcon: iconName, categoryId: id, cost: nil)
                data.append(newCategory)
            }

            // 선택된 인덱스 패스에 해당하는 셀만 리로드
            if let indexPath = selectedIndexPath {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        } else {
            // selectedIndexPath가 nil인 경우, 전체 테이블 뷰 리로드
            tableView.reloadData()
        }

        //btmBtn 활성화 결정 및 기타 UI 업데이트
        //checkForDuplicateCategoriesAndUpdateUI()
    }


    
    
    func AddCategory() {
        // 직접 추가 화면으로 이동합니다
        let addCategoryVC = AddCategoryViewController(name: "", icon: "", id: -1)
        addCategoryVC.modalPresentationStyle = .fullScreen
        addCategoryVC.delegate = self
        present(addCategoryVC, animated: true)
    }

}


extension GoalCategoryViewController: MoneyAmountTextCellDelegate {
    
    func didChangeAmountText(to newValue: String?, cell: MoneyAmountTextCell, oldValue: String?) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if indexPath.section < data.count {
            if let newAmount = newValue {
                // 옵셔널 바인딩을 사용하여 newAmount가 nil이 아닌 경우에만 실행
                data[indexPath.section].cost = Int64(newAmount) ?? 0
            } else {
                // newAmount가 nil인 경우의 처리, 예를 들어 기본값 설정
                data[indexPath.section].cost = 0 // 또는 적절한 기본값
            }
        } else {
            // indexPath.section이 data 배열의 범위를 벗어난 경우의 처리
            print("섹션 인덱스가 data 배열의 범위를 벗어났습니다.")
        }        
        let newValueNumeric = parseNumericValue(from: newValue)
        let oldValueNumeric = parseNumericValue(from: oldValue)
        var categoryGoalOver = false
        var categoryGoalSumOver = false
        
        // Assuming categoryGoalMaker array has elements for each category with corresponding section
        if categoryGoalMaker.count > indexPath.section {
            // Update the category's budget with the new value
            categoryGoalMaker[indexPath.section].categoryBudget = newValueNumeric
        }
        
        // Update sumAmount
        sumAmount = categoryGoalMaker.reduce(0) { $0 + ($1.categoryBudget ?? 0 ) }
        
        //총합 업데이트 및 디스플레이 반영
        updateSumAmountDisplay()
        
        //moneyAmountTextCell 경고문 변경
        if let cell = tableView.cellForRow(at: indexPath) as? MoneyAmountTextCell {
            if let ga = goalCreationManager.goalBudget {
                if ga < newValueNumeric {
                    categoryGoalOver = true
                    categoryGoalSumOver = true
                }else{
                    categoryGoalOver = false
                }
                
                if ga < sumAmount {
                    categoryGoalSumOver = true
                }else{
                    categoryGoalSumOver = false
                }
            }
            cell.setAmountLabel(categoryGoalSumOver: categoryGoalSumOver, categoryGoalOver: categoryGoalOver)
        }
        
        //progressBar 업데이트
        progressBar.changeUsedAmt(usedAmt: sumAmount, goalAmt: goalCreationManager.goalBudget!)
        
        //btmBtn 활성화 결정
        //checkForDuplicateCategoriesAndUpdateUI()
    }
}


// 카테고리별 목표 금액 입력 화면
class GoalCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddCategoryViewDelegate{
    
    var bottomConstraint: NSLayoutConstraint?

    func AddCategoryCompleted(_ name: String, iconName: String) {
        // 직접 추가 완료 후
    }
    
    ///카테고리 셀을 만들기 위함.
    weak var delegate: CategorySelectionDelegate?
    
    // api 연결
    let viewModel = MufflerViewModel()
    let disposeBag = DisposeBag()
    
    // 카테고리 내용 저장
    struct GoalCategory {
        var categoryName : String
        var categoryIcon : String
        var categoryId : Int64
        var cost : Int64?
    }
    
    var data : [GoalCategory] = []
    
    var currentCellIndex : Int = 0
    //화면 구성 요소
    var descriptionView = DescriptionView(text: "카테고리별 목표 금액을\n입력해주세요", alignToCenter: false)
    var progressBar = GoalProgressBar(goalAmt: 300000, usedAmt: 0) // 임시 값으로 초기화
    let totalCostLabel = MPLabel() //progressBar 안에
    let leftAmountLabel = MPLabel() //progressBar 안에
    var verticalStack = UIStackView()
    var tableView : UITableView!
    var btmBtn = MainBottomBtn(title: "다음")
    
    var selectedIndexPath : IndexPath?
    
    //카테고리 목표금액의 합
    var sumAmount : Int64 = 0
    
    //카테고리별 목표
    var categoryGoalMaker : [Category] = [] //같은 카테고리 목표는 모달에서 막아야함.
    /// categoryGoalMaker를 인자로 넘겨주고,
    /// 여기에 겹치는 id를 가진 버튼만 전부 disable 시킬 수 있게 만들어야함.
    
    //카테고리 셀의 수 - 1의 값
    var categoryCount : Int = 1
    
    //목표 생성용
    private let goalCreationManager = GoalCreationManager.shared // 목표 생성용
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    
        setupDescriptionView()
        setupStackView()
        setupBtmBtn()
        setupTableView()
        
        btmBtn.isEnabled = true
    }
    
    // 여기서부터 setup 메서드들을 정의합니다.
    @objc func btmButtonTapped() {
        // Collect category goals from the UI
        var categoryGoals = [CategoryGoal]()
    
        for section in 0..<categoryCount - 1 {  // Exclude the "Add Category" section
            if let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? GoalCategoryTableViewCell,
               let amountCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as? MoneyAmountTextCell,
               let categoryId = categoryCell.categoryId,
               let categoryBudgetText = amountCell.textField.text,
               let categoryBudget = Int64(categoryBudgetText.replacingOccurrences(of: ",", with: "")) {
                
                let categoryGoal = CategoryGoal(categoryGoalId: Int64(-1), categoryId: categoryId, categoryBudget: categoryBudget)
                categoryGoals.append(categoryGoal)
            }
        }
        
        // Add category goals to the goalCreationManager
       goalCreationManager.addCategoryGoals(categoryGoals: categoryGoals)
        
        // Proceed to the next view controller or show an error/alert if needed
        let goalDailyVC = GoalDailyViewController()
        navigationController?.pushViewController(goalDailyVC, animated: true)
    }
    
//    private func setupHeader() {
//        header.translatesAutoresizingMaskIntoConstraints = false
//        header.addBackButtonTarget(target: self, action: #selector(backButtonTapped), for: .touchUpInside)
//        view.addSubview(header)
//        
//        NSLayoutConstraint.activate([
//            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            header.heightAnchor.constraint(equalToConstant: 60) // 예시 높이값
//        ])
//    }
    
    @objc private func backButtonTapped() {
        // 뒤로 가기 기능 구현
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
    
    //스택 생성
    private func setupStackView() {
        
        updateSumAmountDisplay()
        totalCostLabel.font = UIFont.systemFont(ofSize: 14)
        leftAmountLabel.font = .mpFont14B()
        
        //가로 스택 뷰를 생성하고 component 추가
        let horizontalStack = UIStackView(arrangedSubviews: [totalCostLabel, leftAmountLabel])
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .equalSpacing
        horizontalStack.alignment = .center
        
        //Vstack를 생성, progressBar와 hstack추가
        verticalStack = UIStackView(arrangedSubviews: [progressBar, horizontalStack])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(verticalStack)
        
        //Vstack auotolayout
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 20),
            verticalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verticalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        progressBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    
    // setUpBtmBtn 메소드 구현
    private func setupBtmBtn() {
        btmBtn.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(btmBtn)
           btmBtn.addTarget(self, action: #selector(btmButtonTapped), for: .touchUpInside)

           let guide = view.safeAreaLayoutGuide
           bottomConstraint = btmBtn.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -30)
           bottomConstraint?.isActive = true

           NSLayoutConstraint.activate([
               btmBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               btmBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
               btmBtn.heightAnchor.constraint(equalToConstant: 50)
           ])
        
        // 키보드 알림 구독
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // 키보드가 나타날 때 호출되는 메소드
    @objc func keyboardWillShow(notification: NSNotification) {
        adjustForKeyboard(notification: notification, show: true)
        
    }
    
    // 키보드가 사라질 때 호출되는 메소드
    @objc func keyboardWillHide(notification: NSNotification) {
        adjustForKeyboard(notification: notification, show: false)
    }
    
    // 키보드 나타남/사라짐에 따른 뷰 조정 메소드
    private func adjustForKeyboard(notification: NSNotification, show: Bool) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        print(keyboardHeight)
        let adjustmentHeight = show ? -keyboardHeight + 30 : -30.0

        if let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: animationDuration) {
                self.bottomConstraint?.constant = adjustmentHeight
                self.view.layoutIfNeeded()
            }
        }
    }


    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped) // Use .grouped for section headers
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: CustomSectionHeaderView.identifier)
        tableView.register(GoalCreateCategoryBtnCell.self, forCellReuseIdentifier: "GoalCreateCategoryBtnCell")
        tableView.register(GoalCategoryTableViewCell.self, forCellReuseIdentifier: "GoalCategoryTableViewCell")
        tableView.register(MoneyAmountTextCell.self, forCellReuseIdentifier: "MoneyAmountTextCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100 // Give an estimated row height for better performance
        tableView.separatorStyle = .none  // Remove separator lines if not needed
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: verticalStack.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: btmBtn.topAnchor, constant: -5)
        ])
    }
    
    // MARK: - UITableViewDataSource
    //섹션 개수 지정
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoryCount
    }
    
    //섹션별 row 개수 지정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == categoryCount - 1 ? 1 : 2
    }
    
//    //헤더 텍스트 지정
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "카테고리 목표 \(section + 1)"
//    }
    
    //헤더 뷰 지정 (헤더 텍스트보다 발전)
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomSectionHeaderView.identifier) as? CustomSectionHeaderView else { return nil }
        // 삭제 없데이트
        headerView.titleLabel.text = "카테고리 목표 \(section + 1)"
        headerView.onDeleteButtonTapped = { [weak self] in
            guard let self = self else { return }
               // 배열 범위 확인
//            if section < self.data.count {
//                // 데이터 모델에서 해당 섹션 삭제
//                self.data.remove(at: section)
//                
//                // 테이블 뷰에서 섹션 삭제
//                self.tableView.performBatchUpdates({
//                    self.tableView.deleteSections(IndexSet(integer: section), with: .automatic)
//                }) { completed in
//                    // 필요한 추가 작업 수행, 예를 들어 다른 섹션의 인덱스 업데이트 등
//                    tableView.reloadData() // 전체 테이블 뷰를 새로고침하여 헤더 타이틀 업데이트
//
//                }
//            }
            //금액 빼고
            sumAmount -= categoryGoalMaker[section].categoryBudget ?? 0
            //초기화 시키고
            self.resetCategorySection(section)
            //삭제
            self.categoryGoalMaker.remove(at: section)
            self.categoryCount -= 1
            
            // 섹션 삭제 후 테이블 뷰 업데이트
            tableView.performBatchUpdates({
                self.tableView.deleteSections([section], with: .automatic)
            }) { completed in
                // 삭제 완료 후 필요한 경우 추가 작업 수행
                self.tableView.reloadData() // 전체 테이블 뷰를 새로고침하여 헤더 타이틀 업데이트
                self.view.layoutIfNeeded() // 뷰 업데이트

            }
            
            updateSumAmountDisplay()
            progressBar.changeUsedAmt(usedAmt: sumAmount, goalAmt: goalCreationManager.goalBudget!)
            
            //btmBtn 활성화 체크
            //checkForDuplicateCategoriesAndUpdateUI()
        }
        
        if section == categoryCount - 1 {
            headerView.disableDeleteBtn()
        }else {
            
            
            headerView.ableDeleteBtn()
        }
        
        return headerView
    }
    
    //헤더 높이 지정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    //섹션, row 별 셀 종류 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(currentCellIndex)
        currentCellIndex = indexPath.section
        print(data)
        print(categoryCount, indexPath.section)
        if indexPath.section == categoryCount - 1  {
            // 마지막 섹션에 GoalCreateCategoryBtnCell 배치
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCreateCategoryBtnCell", for: indexPath) as! GoalCreateCategoryBtnCell
            cell.onAddButtonTapped = { [weak self] in
                guard let self = self else { return }
                
                self.categoryCount += 1  // 카테고리 수 증가
                
                let newCategory = Category(id: -1, name: "")// TODO : id는 나중에
                self.categoryGoalMaker.append(newCategory)

                // 새로운 카테고리 정보 초기화
                let add = GoalCategory(categoryName: "카테고리 선택", categoryIcon: "icon_category", categoryId: -1, cost: nil)
                self.data.append(add)
                
                // 새로운 섹션을 삽입
                self.tableView.beginUpdates()
                self.tableView.insertSections([self.categoryCount - 2], with: .automatic)
                self.tableView.endUpdates()

                // 전체 테이블 뷰를 리로드하여 헤더를 업데이트
                self.tableView.reloadData()
                
        
                
                //btmBtn 체크
                //checkForDuplicateCategoriesAndUpdateUI()
            }
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCategoryTableViewCell", for: indexPath) as! GoalCategoryTableViewCell
                // 현재 섹션의 데이터를 가져옴
                let category = data[indexPath.section]
                cell.configureCell(categoryId: category.categoryId, text: category.categoryName, iconName: category.categoryIcon)
                cell.isModified = category.categoryId != -1 // categoryId가 -1이 아니면 수정된 것으로 간주
                return cell
            }
            else {
            }
                // Dequeue MoneyAmountTextCell for amount input
                let cell = tableView.dequeueReusableCell(withIdentifier: "MoneyAmountTextCell", for: indexPath) as! MoneyAmountTextCell
                if indexPath.section < data.count {
                    // 이미 추가된 금액이 있는 경우
                    let dataIndex = data[indexPath.section]
                    cell.configureCell(image: UIImage(named: "icon_Wallet"), placeholder: "목표 금액", cost: String(dataIndex.cost ?? 0))
                
                }else{
                    
                cell.textField.text = nil
                cell.amountLabel.text = ""
                cell.configureCell(image: UIImage(named: "icon_Wallet"), placeholder: "목표 금액", cost: "")
                            }
            cell.delegate = self
            
            return cell

        }
        
    }
    
    // UITableViewDelegate 메서드 구현
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    //선택된 셀을 늘 추적 => 버튼이 눌렸다고 셀이 선택된건 아니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        print("선택된 셀의 섹션: \(indexPath.section), 행: \(indexPath.row)")
        
        if(indexPath.row == 0){
            self.selectedIndexPath = indexPath
            
            // 모달 표시
            showCategoryModal()
            //indexpath로 찾은 cell의 isModified를 true로 바꾸기
            if let cell = tableView.cellForRow(at: indexPath) as? GoalCategoryTableViewCell {
                cell.isModified = true
            }
        }
    }
        
    private func showCategoryModal() {
        print("클릭 : 카테고리 선택을 위해 카테고리 선택 모달로 이동합니다")

        // 카테고리 조회 하기
        viewModel.getCategoryFilter()
            .subscribe(onNext: { [weak self] repos in
                guard let self = self else { return }
                // 네트워크 응답에 대한 처리
                print(repos)
                let categories = repos.result.categories
                let categoryModalVC = CategoryModalViewController(categories: categories)
                categoryModalVC.delegate = self
                self.present(categoryModalVC, animated: true)
            }, onError: { error in
                // 에러 처리
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)

    }
    
    //총금액 알려주는 구간 업데이트
    private func updateSumAmountDisplay() {
        let formattedSumAmount = formatNumber(sumAmount)
        let goalBudget = goalCreationManager.goalBudget ?? 0
        let formattedGoalAmount = formatNumber(goalBudget)
        
        let text = "\(formattedSumAmount)원 / \(formattedGoalAmount)원"
        
        // NSAttributedString을 사용하여 다른 색상 적용
        let attributedString = NSMutableAttributedString(string: text)
        
        // '/' 기호를 기준으로 전후 텍스트의 범위를 찾음
        if let range = text.range(of: "/") {
            let preSlashRange = NSRange(text.startIndex..<range.lowerBound, in: text)
            let fromSlashRange = NSRange(range.lowerBound..<text.endIndex, in: text) //endIndex 포함시 오버플로우
            attributedString.addAttribute(.foregroundColor, value: UIColor.mpDarkGray, range: preSlashRange )
            attributedString.addAttribute(.foregroundColor, value: UIColor.mpGray, range: fromSlashRange)
        }
        
        totalCostLabel.attributedText = attributedString
        
        let leftAmount = goalBudget > sumAmount ? goalBudget - sumAmount : sumAmount - goalBudget
        let formattedLeftAmount = formatNumber(leftAmount)
        leftAmountLabel.text = goalBudget > sumAmount ? "남은 금액 \(formattedLeftAmount)원" : "초과 금액 \(formattedLeftAmount)원"
        leftAmountLabel.textColor = goalBudget >= sumAmount ? .mpBlack : .mpRed
        
        btmBtn.isEnabled = !(sumAmount > goalBudget) // 사실 모든 카테고리가 다 선택되었는지 점검하는 기능도 추가해야함.
    }

    //컴마 넣기
    private func formatNumber(_ number: Int64) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal // Use .decimal for formatting with commas.
        return numberFormatter.string(from: NSNumber(value: number)) ?? "0"
    }
    
    //컴마 빼기
    private func parseNumericValue(from value: String?) -> Int64 {
        guard let value = value?.replacingOccurrences(of: ",", with: "") else { return 0 }
        return Int64(value) ?? 0
    }
    
    
    func resetCategorySection(_ section: Int) {
        // 데이터 모델 초기화
        let resetCategory = Category(id: 0, name: "")
        categoryGoalMaker[section] = resetCategory
        
        // 섹션 리로드 전에 셀 내용 초기화
        if let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? GoalCategoryTableViewCell {
            // 카테고리 셀 내용 초기화
            categoryCell.textField.text = "카테고리를 선택해주세요" // 또는 기본 텍스트
            categoryCell.iconImageView.image = UIImage(systemName: "icon_category") // 기본 아이콘 설정
            categoryCell.isModified = false //수정 여부 판단
        }
        
        if let amountCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as? MoneyAmountTextCell {
            // 금액 입력 셀 내용 초기화
            amountCell.textField.text = nil // 텍스트 필드 초기화
            amountCell.amountLabel.text = "입력값이 없습니다." // 금액 레이블 초기화
        }
        
        // 해당 섹션만 리로드하여 변경사항 반영
        tableView.reloadSections(IndexSet(integer: section), with: .fade)
    }

    //모든 셀이 준비가 됐는지 확인함.
    func checkAllSections() -> Bool {
        var allConditionsMet = true
        
        //전부 modified 됐나
        for section in 0..<categoryCount - 1 {  // Exclude the last section which is the add button
            // Check if the category has been modified
            if let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? GoalCategoryTableViewCell,
               !categoryCell.isModified {
                allConditionsMet = false
                break
            }
            
            // Check if the amount text is not empty
            if let amountCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as? MoneyAmountTextCell,
               amountCell.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                allConditionsMet = false
                break
            }
        }
        
        //목표금액 언더인가 체크
        if sumAmount > goalCreationManager.goalBudget! {
            allConditionsMet = false
        }
        
        //        // Enable or disable the button based on whether all conditions are met
        //        btmBtn.isEnabled = allConditionsMet
        
        return allConditionsMet
    }
    
    //    func updateCellsForGoalAmountChange() {
    //        // goalBudget가 goalCreationManager.goalBudget보다 작거나 같은지 확인
    //        let isGoalAmountExceeded = sumAmount > goalCreationManager.goalBudget!
    //
    //        for section in 0..<categoryCount - 1 {  // 마지막 "추가" 섹션은 제외
    //            if let amountCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as? MoneyAmountTextCell {
    //                // 각 MoneyAmountTextCell의 상태 업데이트
    //                if !isGoalAmountExceeded {
    //                    // 개별 카테고리 금액이 목표 금액을 초과하지 않는 경우
    //                    amountCell.categoryGoalOver = false
    //                    amountCell.categoryGoalSumOver = false
    //                }
    //            }
    //        }
    //
    //        // 모든 조건이 충족되는지 확인하고 버튼 상태 업데이트
    //        checkAllSectionsAndEnableButton()
    //    }
    
    //같은 이름의 카테고리가 있는지 확인
    func checkForDuplicateCategoriesAndUpdateUI() {
        var categoryNames = [String: Int]() // Track occurrences of each category name
        var duplicatesFound = false
        
        for section in 0..<categoryCount - 1 { // Exclude the add button section
            if let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? GoalCategoryTableViewCell,
               let categoryName = categoryCell.textField.text, categoryCell.isModified {
                categoryNames[categoryName, default: 0] += 1
                if categoryNames[categoryName]! > 1 {
                    duplicatesFound = true // Mark as duplicate found
                }
            }
        }
        
        // Update UI based on duplicates
        for section in 0..<categoryCount - 1 {
            if let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? GoalCategoryTableViewCell,
               let categoryName = categoryCell.textField.text {
                let isDuplicate = categoryNames[categoryName]! > 1
                updateCellUI(categoryCell, isDuplicate: isDuplicate)
            }
        }
        
        // Update bottom button enabled state
        btmBtn.isEnabled = !duplicatesFound && checkAllSections()
    }
    
    //같은 이름의 카테고리의 테두리를 빨갛게 만들기 위해
    func updateCellUI(_ cell: GoalCategoryTableViewCell, isDuplicate: Bool) {
        if isDuplicate {
            // Apply red border for duplicate
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.borderColor = UIColor.red.cgColor
        } else {
            // Remove border for non-duplicate
            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.borderColor = nil
        }
    }
    
}


//커스텀 섹션 헤더뷰
class CustomSectionHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "CustomSectionHeaderView"//이런식으로 유일한 identifier 강제 가능
    
    let titleLabel = MPLabel()
    let deleteButton = UIButton()
    
    var onDeleteButtonTapped: (() -> Void)?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        titleLabel.textColor = UIColor(hexCode: "979797") // 등록할까?
        titleLabel.font = .mpFont14M()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(deleteButton)
        
        // Configure titleLabel and deleteButton layout...
        deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        deleteButton.tintColor = .mpGray
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    //+셀에서 x 없애고 나타내기
    func ableDeleteBtn(){
        deleteButton.isHidden = false
    }
    
    func disableDeleteBtn(){
        deleteButton.isHidden = true
    }
    
    @objc func deleteButtonTapped() {
        onDeleteButtonTapped?()
    }
    
    
}



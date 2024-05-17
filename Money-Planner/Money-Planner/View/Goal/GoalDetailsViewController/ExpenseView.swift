//
//  ExpenseView.swift
//  Money-Planner
//
//  Created by 유철민 on 2/28/24.
//

import Foundation
import UIKit

// Protocol for handling actions within ExpenseView, like selecting an expense detail
protocol ExpenseViewDelegate: AnyObject {
    func navigateToDailyConsumeViewController(date: String, totalAmount: Int64)
    func didRequestToFetchMoreData()
}


class ExpenseView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: ExpenseViewDelegate?
    var isEnabled = true
    
    var tapFilterBtn: (() -> Void)?
    var tapPeriodFilterBtn : (() -> Void)?
    var tapFilterCancelBtn1 : (() -> Void)?
    var tapCategoryFilterBtn : (() -> Void)?
    var tapFilterCancelBtn2 : (() -> Void)?
    
    private var leadingConstraintForCategoryFilterBtn: NSLayoutConstraint?
    private var leadingConstraintForFilterCancelBtn2: NSLayoutConstraint?
    
    // 날짜 필터 버튼
    let filterBtn: LabelAndImageBtn = {
        let button = LabelAndImageBtn(type: .system)
        button.setTitle("소비내역 필터링 ", for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.setTitleColor(.mpCharcoal, for: .normal)
        button.titleLabel?.font = .mpFont12M()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let periodFilterBtn: LabelAndImageBtn = {
        let button = LabelAndImageBtn(type: .system)
        button.setTitle("전체 기간 조회", for: .normal)
//        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.setTitleColor(.mpMainColor, for: .normal)
        button.titleLabel?.font = .mpFont12M()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let filterCancelBtn1 : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .mpCharcoal
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let categoryFilterBtn: LabelAndImageBtn = {
        let button = LabelAndImageBtn(type: .system)
        button.setTitle("전체 카테고리 조회 ", for: .normal)
//        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.setTitleColor(.mpMainColor, for: .normal)
        button.titleLabel?.font = .mpFont12M()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let filterCancelBtn2 : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .mpCharcoal
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    @objc private func filterButtonTapped() {
        tapFilterBtn?()
    }
    
    @objc private func periodFilterButtonTapped() {
        tapPeriodFilterBtn?()
    }
    
    @objc private func filterCancelBtn1Tapped() {
        tapFilterCancelBtn1?()
    }
    
    @objc private func categoryFilterButtonTapped() {
        tapCategoryFilterBtn?()
    }
    
    @objc private func filterCancelBtn2Tapped() {
        tapFilterCancelBtn2?()
    }
    
    let filterBtnView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // 필요한 경우 추가적인 스타일 설정
        return view
    }()
    
    private var filterBtnViewHeightConstraint: NSLayoutConstraint?

    let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = true
        table.separatorStyle = .none
        table.backgroundColor = .clear
        return table
    }()
    
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "소비내역이 없습니다."
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    var data: [DailyExpense] = [] {
        didSet {
            tableView.isHidden = data.isEmpty
            noDataLabel.isHidden = !data.isEmpty
            tableView.reloadData()
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
    
//    func update(with dailyExpenses: [DailyExpense]) {
//        self.data = dailyExpenses
//    }
    
    func update(with dailyExpenses: [DailyExpense], filteringBy selectedCategory: [String: Bool]? = nil) {
        // selectedCategory가 nil 또는 비어있는 경우, 모든 항목 표시
        guard let selectedCategory = selectedCategory, !selectedCategory.isEmpty else {
            self.data = dailyExpenses
            return
        }

        // selectedCategory가 비어있지 않은 경우, 선택된 카테고리에 해당하는 항목만 필터링
        self.data = dailyExpenses.map { dailyExpense -> DailyExpense in
            let filteredDetails = dailyExpense.expenseDetailList.filter { detail in
                // 선택된 카테고리에 포함되어 있고, 해당 카테고리가 true로 설정된 항목만 반환
                return selectedCategory[detail.categoryIcon] ?? false
            }
            // 필터링된 세부 항목들로 새로운 DailyExpense 객체 생성
            return DailyExpense(date: dailyExpense.date, dailyTotalCost: dailyExpense.dailyTotalCost, expenseDetailList: filteredDetails)
        }.filter { !$0.expenseDetailList.isEmpty } // 세부 항목이 하나도 없는 날짜는 제외
    }

    
    func applyFilteringBySelectedCategory(_ selectedCategory: [String: Bool]?) {
        guard let selectedCategory = selectedCategory else {
            // selectedCategory가 nil인 경우, 모든 항목을 표시 (필터링을 해제)
            // 이 경우, 기본적으로 모든 항목을 다시 표시하거나, 기존 상태를 유지합니다.
            // 필요에 따라 기존 데이터를 재조회하거나, 별도의 로직을 추가할 수 있습니다.
            return
        }
        
        // 현재 data를 기반으로 필터링 수행
        self.data = self.data.map { dailyExpense -> DailyExpense in
            let filteredDetails = dailyExpense.expenseDetailList.filter { detail in
                // 선택된 카테고리에 포함되어 있고, 해당 카테고리가 true로 설정된 항목만 반환
                return selectedCategory[detail.categoryIcon] ?? false
            }
            // 필터링된 세부 항목들로 새로운 DailyExpense 객체 생성
            return DailyExpense(date: dailyExpense.date, dailyTotalCost: dailyExpense.dailyTotalCost, expenseDetailList: filteredDetails)
        }.filter { !$0.expenseDetailList.isEmpty } // 세부 항목이 하나도 없는 날짜는 제외

        // 필터링 결과에 따라 UI 업데이트 등의 추가 작업을 수행할 수 있습니다.
    }

    
    private func setupUI() {
        
        addSubview(filterBtnView)
        
        // filterBtnView에 버튼 추가
        filterBtnView.addSubview(filterBtn)
        filterBtnView.addSubview(periodFilterBtn)
        filterBtnView.addSubview(filterCancelBtn1)
        filterBtnView.addSubview(categoryFilterBtn)
        filterBtnView.addSubview(filterCancelBtn2)
        
        // 버튼 타겟 설정
        filterBtn.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        periodFilterBtn.addTarget(self, action: #selector(periodFilterButtonTapped), for: .touchUpInside)
        filterCancelBtn1.addTarget(self, action: #selector(filterCancelBtn1Tapped), for: .touchUpInside)
        categoryFilterBtn.addTarget(self, action: #selector(categoryFilterButtonTapped), for: .touchUpInside)
        filterCancelBtn2.addTarget(self, action: #selector(filterCancelBtn2Tapped), for: .touchUpInside)
        
        addSubview(tableView)
        addSubview(noDataLabel)
        
        filterBtnViewHeightConstraint = filterBtnView.heightAnchor.constraint(equalToConstant: 60)
        filterBtnViewHeightConstraint?.isActive = true
        
        // filterBtnView 제약 조건 설정
        NSLayoutConstraint.activate([
            filterBtnView.topAnchor.constraint(equalTo: self.topAnchor),
            filterBtnView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            filterBtnView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        // filterBtn 제약 조건 설정 (이전과 동일)
        NSLayoutConstraint.activate([
            filterBtn.leadingAnchor.constraint(equalTo: filterBtnView.leadingAnchor, constant: 16),
            filterBtn.topAnchor.constraint(equalTo: filterBtnView.topAnchor, constant: 16),
        ])
        
        // 나머지 버튼들을 filterBtn의 아래에 일렬로 배치하는 제약 조건 설정
        let buttonSpacing = CGFloat(4) // 버튼 간의 간격

        
        NSLayoutConstraint.activate([
            // periodFilterBtn 위치 설정
            periodFilterBtn.leadingAnchor.constraint(equalTo: filterBtnView.leadingAnchor, constant: 16),
            periodFilterBtn.topAnchor.constraint(equalTo: filterBtn.bottomAnchor, constant: buttonSpacing),
            periodFilterBtn.heightAnchor.constraint(equalToConstant : 10),
            
            // filterCancelBtn1 위치 설정
            filterCancelBtn1.leadingAnchor.constraint(equalTo: periodFilterBtn.trailingAnchor, constant: buttonSpacing),
            filterCancelBtn1.centerYAnchor.constraint(equalTo: periodFilterBtn.centerYAnchor, constant: -1),
            filterCancelBtn1.widthAnchor.constraint(equalToConstant: 10),
            filterCancelBtn1.heightAnchor.constraint(equalToConstant : 10),
            
            // categoryFilterBtn 위치 설정
//            categoryFilterBtn.leadingAnchor.constraint(equalTo: filterCancelBtn1.trailingAnchor, constant: buttonSpacing),
            categoryFilterBtn.centerYAnchor.constraint(equalTo: periodFilterBtn.centerYAnchor),
            categoryFilterBtn.heightAnchor.constraint(equalToConstant : 10),
            
            // filterCancelBtn2 위치 설정
//            filterCancelBtn2.leadingAnchor.constraint(equalTo: categoryFilterBtn.trailingAnchor, constant: buttonSpacing),
            filterCancelBtn2.centerYAnchor.constraint(equalTo: periodFilterBtn.centerYAnchor, constant: -1),
            filterCancelBtn2.widthAnchor.constraint(equalToConstant: 10),
            filterCancelBtn2.heightAnchor.constraint(equalToConstant : 10),
        ])
        
        leadingConstraintForCategoryFilterBtn = categoryFilterBtn.leadingAnchor.constraint(equalTo: filterCancelBtn1.trailingAnchor, constant: buttonSpacing)
        leadingConstraintForFilterCancelBtn2 = filterCancelBtn2.leadingAnchor.constraint(equalTo: categoryFilterBtn.trailingAnchor, constant: buttonSpacing)
        
        // 기본적으로는 이 제약 조건들을 비활성화
        leadingConstraintForCategoryFilterBtn?.isActive = false
        leadingConstraintForFilterCancelBtn2?.isActive = false
        
        // tableView 제약 조건 설정
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: filterBtnView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            noDataLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        // 필요한 tableView 설정
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConsumeRecordCell.self, forCellReuseIdentifier: "ConsumeRecordCell")
        tableView.register(ConsumeRecordPagingCell.self, forCellReuseIdentifier: "ConsumeRecordPagingCell")
        
        backgroundColor = .mpWhite
        
        // 초기에 숨겨진 버튼들을 관리
        periodFilterBtn.isHidden = true
        filterCancelBtn1.isHidden = true
        categoryFilterBtn.isHidden = true
        filterCancelBtn2.isHidden = true
    }

    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return data[section].expenseDetailList.count
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 마지막 섹션인 경우, '더보기' 셀을 위해 행의 수를 1 증가
        if section == data.count - 1 {
            return data[section].expenseDetailList.count + 1 // +1 for the paging cell
        }
        return data[section].expenseDetailList.count
    }

    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConsumeRecordCell", for: indexPath) as? ConsumeRecordCell else {
//            fatalError("Unable to dequeue ConsumeRecordCell")
//        }
//        let expenseDetail = data[indexPath.section].expenseDetailList[indexPath.row]
//        cell.configure(with: expenseDetail)
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 마지막 섹션의 마지막 행인지 확인
        if indexPath.section == data.count - 1 && indexPath.row == data[indexPath.section].expenseDetailList.count {
            // ConsumeRecordPagingCell 반환
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConsumeRecordPagingCell", for: indexPath) as? ConsumeRecordPagingCell else {
                fatalError("Unable to dequeue ConsumeRecordPagingCell")
            }
            cell.configure(isEnabled: GoalDetailViewModel.shared.hasNext) // isFetchingMore 상태에 따라 버튼 활성화
//            cell.onAddButtonTapped = self.delegate?.didRequestToFetchMoreData
            cell.onAddButtonTapped = { [weak self] in
                        self?.delegate?.didRequestToFetchMoreData()
                    }
            return cell
        }

        // 기존의 ConsumeRecordCell 반환 로직
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConsumeRecordCell", for: indexPath) as? ConsumeRecordCell else {
            fatalError("Unable to dequeue ConsumeRecordCell")
        }
        let expenseDetail = data[indexPath.section].expenseDetailList[indexPath.row]
        cell.configure(with: expenseDetail)
        return cell
    }

    
    // MARK: UITableViewDelegate
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedExpense = data[indexPath.section].expenseDetailList[indexPath.row]
//        delegate?.didSelectExpenseDetail(expenseId: Int64(selectedExpense.expenseId))
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30 // Adjust the height as needed
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .mpWhite // Customize the background color
        
        let separatorView = UIView()
        separatorView.backgroundColor = .mpGypsumGray // Customize separator color
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(separatorView)
        
        let label = UILabel()
        label.font = .mpFont14M() // Customize the font
        label.textColor = UIColor(hexCode: "9FAAB0") // Customize the text color
        label.text = data[section].date.toDate?.toString(format: "yyyy년 MM월 dd일") // Use your date format
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        
        let totalCostButton = UIButton(type: .system)
        let dateText = data[section].date //.toDate?.toString(format: "yyyy-MM-dd")
        totalCostButton.setTitle("\(setComma(cash: data[section].dailyTotalCost))원", for: .normal)
        totalCostButton.setImage(UIImage(named : "btn_arrow"), for: .normal)
        totalCostButton.tintColor = .mpDarkGray
        totalCostButton.contentHorizontalAlignment = .right
        totalCostButton.semanticContentAttribute = .forceRightToLeft
        totalCostButton.setTitleColor(.mpDarkGray, for: .normal)
        totalCostButton.titleLabel?.font = .mpFont14M()
        totalCostButton.imageView?.contentMode = .scaleAspectFit // Set image content mode
        totalCostButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        totalCostButton.translatesAutoresizingMaskIntoConstraints = false
        // Store the section date in the accessibilityIdentifier for retrieval in the action method
        totalCostButton.accessibilityIdentifier = dateText
        totalCostButton.addTarget(self, action: #selector(tappedDailyConsumeBtn(sender: )), for: .touchUpInside)
        headerView.addSubview(totalCostButton)
        
        
        // Constraints for separatorView
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Constraints for label
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // Constraints for totalCostButton
        NSLayoutConstraint.activate([
            totalCostButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            totalCostButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            totalCostButton.widthAnchor.constraint(equalToConstant: 200) // Adjust width as needed
        ])
        
        return headerView
    }


    private func setComma(cash: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: cash)) ?? ""
    }

    
//    @objc func handleHeaderTap(_ gesture: UITapGestureRecognizer) {
//        guard let section = gesture.view?.tag else { return }
//        let date = data[section].date.toDate?.toString(format: "yyyy.MM.dd") ?? "Unknown Date"
//        delegate?.didTapSectionHeader(date: date)
//    }
//    
//    func didTapSectionHeader(date: String) {
//        print(date) // Now prints the date of the tapped section header
//    }
    
//    @objc func tappedDailyConsumeBtn(sender: UIButton) {
//        if let date = sender.accessibilityIdentifier {
//            // Assuming you have access to calculate or retrieve the total amount for the given date.
//            // For demonstration, I'm using a placeholder value. You should replace this with your actual total amount calculation or retrieval logic.
//            let totalAmount = Int64(sender.currentTitle)! // Your logic to get the total amount for this date
//            delegate?.navigateToDailyConsumeViewController(date: date, totalAmount: totalAmount)
//        }
//    }
    
    @objc func tappedDailyConsumeBtn(sender: UIButton) {
        if let dateIdentifier = sender.accessibilityIdentifier,
           let sectionIndex = data.firstIndex(where: { $0.date == dateIdentifier }) {
            let totalAmount = data[sectionIndex].dailyTotalCost
            delegate?.navigateToDailyConsumeViewController(date: dateIdentifier, totalAmount: totalAmount)
        }else {
            print("Date unknown or section not found")
            return
        }
    }
    
    func setFilterBtnViewHeight(to height: CGFloat) {
        // 높이 제약 조건을 변경합니다.
        filterBtnViewHeightConstraint?.constant = height
        
        // 레이아웃을 즉시 업데이트합니다.
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func adjustFilterButtonPositions() {
        // 이전에 설정했던 모든 제약 조건을 비활성화
        NSLayoutConstraint.deactivate([leadingConstraintForCategoryFilterBtn, leadingConstraintForFilterCancelBtn2].compactMap { $0 })
        
        if periodFilterBtn.isHidden {
            // periodFilterBtn이 숨겨진 경우, categoryFilterBtn을 filterBtn의 바로 아래에 위치시킵니다.
            leadingConstraintForCategoryFilterBtn = categoryFilterBtn.leadingAnchor.constraint(equalTo: filterBtnView.leadingAnchor, constant: 16)
        } else {
            // periodFilterBtn이 표시된 경우, categoryFilterBtn을 periodFilterBtn과 filterCancelBtn1의 오른쪽에 위치시키고, 간격을 16으로 설정합니다.
            leadingConstraintForCategoryFilterBtn = categoryFilterBtn.leadingAnchor.constraint(equalTo: filterCancelBtn1.trailingAnchor, constant: 16)
        }
        
        // filterCancelBtn2의 위치는 항상 categoryFilterBtn의 오른쪽입니다.
        leadingConstraintForFilterCancelBtn2 = filterCancelBtn2.leadingAnchor.constraint(equalTo: categoryFilterBtn.trailingAnchor, constant: 4)

        // 새로운 제약 조건을 활성화
        NSLayoutConstraint.activate([leadingConstraintForCategoryFilterBtn, leadingConstraintForFilterCancelBtn2].compactMap { $0 })

        // 변경된 제약 조건에 따라 레이아웃 업데이트
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

}


class ConsumeRecordPagingCell: UITableViewCell {

    var onAddButtonTapped: (() -> Void)?
    
    @objc private func addButtonAction() {
        onAddButtonTapped?()
    }
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("아래로 스와이프하여 더보기", for: .normal)
        button.setTitleColor(.mpGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(ConsumeRecordPagingCell.self, action: #selector(addButtonAction), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(moreButton)
        
        NSLayoutConstraint.activate([
            moreButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            moreButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            moreButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            moreButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
    
    func configure(isEnabled: Bool) {
        moreButton.isEnabled = isEnabled
        if isEnabled {
            moreButton.setTitle("아래로 스와이프하여 더보기", for: .normal)
        } else {
            moreButton.setTitle("더 이상 소비내역이 없어요", for: .disabled)
        }
    }
}


extension ExpenseView: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 스크롤 뷰의 현재 오프셋, 콘텐츠 높이, 뷰 높이를 가져옵니다.
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        // 사용자가 스크롤 뷰의 맨 아래 근처에 도달했는지 확인합니다.
        // 'threshold' 값은 더 일찍 데이터 로딩을 시작하고 싶을 때 조절할 수 있습니다.
        let threshold = CGFloat(100.0) // 필요에 따라 조절 가능
        if currentOffset > maximumOffset - threshold {
            // 맨 아래에 도달했을 때의 액션을 실행합니다.
            delegate?.didRequestToFetchMoreData()
            print("RequestToFetchMoreData")
        }
    }
}

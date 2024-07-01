//
//  GoalDailyViewController.swift
//  Money-Planner
//
//  Created by 유철민 on 1/26/24.
//


import Foundation
import UIKit
import FSCalendar

extension GoalDailyViewController: GoalAmountModalViewControllerDelegate {
    func didChangeAmount(to newAmount: String, for date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateKey = dateFormatter.string(from: date)
        
        // Update the amountInfo dictionary and reload the calendar
        amountInfo[dateKey] = newAmount
        isEdited[dateKey] = true
        sumAmount = convertToInt64Array(from: amountInfo).reduce(0, +)
        
        refreshAmountInfo(startDate: goalCreationManager.startDate!.toDate ?? Date(), endDate: goalCreationManager.endDate!.toDate ?? Date())
        
        customCalendarView.calendar.reloadData()
        
        if calculateTotalAmount(from: goalCreationManager.startDate!.toDate ?? Date(), to: goalCreationManager.endDate?.toDate ?? Date()) <= goalCreationManager.goalBudget ?? 0 {
            btmBtn.isEnabled = true
        }else{
            btmBtn.isEnabled = false
        }
    }
}

class GoalDailyViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    private let descriptionView = DescriptionView(text: "하루하루의 목표금액을\n조정해주세요", alignToCenter: false)
    
//    private let subdescriptionView = SubDescriptionView(text: "일정에 맞게 일일 목표 금액을 변경하면\n나머지 금액은 1/n 해드릴게요", alignToCenter: false)
    
    var progressBar = GoalProgressBar(goalAmt: 300000, usedAmt: 0) // 임시 값으로 초기화
    let totalCostLabel = MPLabel() //progressBar 안에
    let leftAmountLabel = MPLabel() //progressBar 안에
    var verticalStack = UIStackView()
    
    private let btmBtn = MainBottomBtn(title: "다음")
    
    private let goalCreationManager = GoalCreationManager.shared
    
    var isEdited: [String: Bool] = [:]
    var amountInfo: [String: String] = [:]
    
    var sumAmount : Int64 = 0 {
        didSet{
            progressBar.changeUsedAmt(usedAmt: sumAmount, goalAmt: goalCreationManager.goalBudget!)
            updateSumAmountDisplay()
        }
    }
    
    var customCalendarView: CustomCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // CustomCalendarView 인스턴스 생성 및 뷰에 추가
        customCalendarView = CustomCalendarView()
        customCalendarView.calendar.delegate = self
        customCalendarView.calendar.dataSource = self
        
        customCalendarView.calendar.appearance.selectionColor = .clear
        customCalendarView.calendar.appearance.titleSelectionColor = .mpBlack
        
        customCalendarView.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 사용 설정
        view.addSubview(customCalendarView)
        
        if let start = goalCreationManager.startDate?.toDate, let end = goalCreationManager.endDate?.toDate {
            customCalendarView.setPeriod(startDate: start, endDate: end)
            initializeArray(start: start, end: end)
        }
    
        setupViews()
        setupConstraints()
        setupWeekdayLabels()
        
        btmBtn.addTarget(self, action: #selector(btmButtonTapped), for: .touchUpInside)
//        btmBtn.isEnabled = true
         
        self.tabBarController?.tabBar.isHidden = true
        
        sumAmount = convertToInt64Array(from: amountInfo).reduce(0, +)
    }
    
//    private func setupNavigationBar() {
//        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(backButtonTapped))
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
//        backButton.image = UIImage(systemName: "chevron.left", withConfiguration: config)
//        backButton.tintColor = .mpBlack
//        
//        navigationItem.leftBarButtonItem = backButton
//    }
    
    private func setupViews() {
        view.addSubview(descriptionView)
//        view.addSubview(subdescriptionView)
        view.addSubview(customCalendarView)
        view.addSubview(btmBtn)
    }
    
    private func setupConstraints() {
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        totalCostLabel.translatesAutoresizingMaskIntoConstraints = false
        leftAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        btmBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descriptionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            descriptionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            descriptionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
            
        setupStackView()
        
        NSLayoutConstraint.activate([
            customCalendarView.topAnchor.constraint(equalTo: verticalStack.bottomAnchor, constant: 20),
            customCalendarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            customCalendarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            customCalendarView.bottomAnchor.constraint(equalTo: btmBtn.topAnchor, constant: -30),
            
            btmBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            btmBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            btmBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            btmBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
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
        verticalStack.spacing = 3
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
    
    private func updateSumAmountDisplay() {
        let formattedSumAmount = setComma(cash: sumAmount)
        let goalBudget = goalCreationManager.goalBudget ?? 0
        let formattedGoalAmount = setComma(cash: goalBudget)
        
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
        let formattedLeftAmount = numberToKorean(leftAmount)
        
        
        if goalBudget == sumAmount {
            leftAmountLabel.text = "총합 \(numberToKorean(sumAmount))원"
        }else {
            leftAmountLabel.text = goalBudget > sumAmount ? "\(formattedLeftAmount)원을 더 채워주세요" : " \(formattedLeftAmount)원이 초과되었어요"
        }
        
        leftAmountLabel.textColor = goalBudget == sumAmount ? .mpBlack : .mpRed
        progressBar.usedAmtBar.backgroundColor = goalBudget == sumAmount ? .mpMainColor : .mpRed
        
        btmBtn.isEnabled = (sumAmount <= goalBudget) // 사실 모든 카테고리가 다 선택되었는지 점검하는 기능도 추가해야함.
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func btmButtonTapped() {
        let goalFinalVC = GoalFinalViewController()
        let budgets = convertToInt64Array(from: amountInfo)
        goalCreationManager.addDailyBudgets(budgets: budgets)
        navigationController?.pushViewController(goalFinalVC, animated: true)
    }
    
    
    ///calendar관련
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 예를 들어, 선택된 날짜에 대한 현재 금액을 가져옵니다. 실제 구현에서는 모델 또는 데이터 소스에서 이 값을 조회해야 합니다.
        //        let currentTotalAmount = calculateEditedAmount(from: goalCreationManager.startDate?.toDate ?? Date(), to: goalCreationManager.endDate?.toDate ?? Date()),
        let currentTotalAmount = calculateTotalAmount(from: (goalCreationManager.startDate?.toDate)!, to: (goalCreationManager.endDate?.toDate)!)
        
//        let todayYear = Calendar.current.component(.year, from: Date())
//        let todayMonth = Calendar.current.component(.month, from: Date())
//        let dateYear = Calendar.current.component(.year, from: date)
//        let dateMonth = Calendar.current.component(.month, from: date)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(2)
        
//        calendar.appearance.titleTodayColor = (todayYear == dateYear && todayMonth == dateMonth) ? .mpBlack : .mpGray
        calendar.setCurrentPage(date, animated: true)
        
        CATransaction.setCompletionBlock {
            // 애니메이션 완료 후에 실행할 작업을 여기에 추가합니다.
            self.presentEditModal(for: date, with: currentTotalAmount)
        }
        
        CATransaction.commit()
        
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "customCell", for: date, at: position) as! CustomFSCalendarCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateKey = dateFormatter.string(from: date)
        
        // Determine if the date is within the start and end date range.
        let isDateInRange = customCalendarView.startDate.flatMap { startDate in
            customCalendarView.endDate.map { endDate in
                date >= startDate && date <= endDate
            }
        } ?? false
        
        // Configure the appearance based on whether the date is in the range.
        if isDateInRange {
            let todayYear = Calendar.current.component(.year, from: Date())
            let todayMonth = Calendar.current.component(.month, from: Date())
            let dateYear = Calendar.current.component(.year, from: date)
            let dateMonth = Calendar.current.component(.month, from: date)
            
            if todayYear == dateYear && todayMonth == dateMonth {
                cell.titleLabel.textColor = .mpBlack
                cell.titleLabel.font = .mpFont18B()
            } else {
                cell.titleLabel.textColor = .mpGray
                cell.titleLabel.font = .mpFont18R()
            }
            
            // Configure background image and amount text if the date is in range.
            cell.configureBackgroundImage(image: UIImage(named: "btn_date_off"))
            cell.configureImageSize(CGSize(width: 30, height: 30)) // Adjust image size
            // If there is an amount info for the date, display it; otherwise, set to empty string.
            if let amount = amountInfo[dateKey] {
                cell.configureAmountText(amount)
            } else {
                cell.configureAmountText("")
            }
        } else {
            cell.titleLabel.textColor = .mpGray
            cell.titleLabel.font = .mpFont18R()
            cell.configureBackgroundImage(image: nil)
            cell.configureAmountText("") // Set to empty string if there's no amount info.
        }
        return cell
    }

    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        guard let startDate = customCalendarView.startDate, let endDate = customCalendarView.endDate else {
            return false
        }
        
        // 오직 startDate와 endDate 사이의 날짜만 선택 가능하게 함
        return date >= startDate && date <= endDate
    }

    
    private func setupWeekdayLabels() {
        let calendarWeekdayView = customCalendarView.calendar.calendarWeekdayView
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        for (index, label) in calendarWeekdayView.weekdayLabels.enumerated() {
            label.text = weekdays[index]
            label.font = .mpFont14B()
        }
    }

    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
    
    private func initializeArray(start: Date, end: Date) {
        var currentDate = start
        let calendar = Calendar.current
        while currentDate <= end {
            let dateString = formatDate(currentDate)
            isEdited[dateString] = false
            amountInfo[dateString] = "0"
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        refreshAmountInfo(startDate: start, endDate: end)
        
        
        // 초기 호출이 정확히 나눠떨어지지 않는 부분 보안하기 위해서 추가
        var total: Int64 = 0
        for value in amountInfo.values {
            if let intValue = Int64(value) {
                // Add the integer value to the total
                total += intValue
            }
        }
        
        let goalBudget = GoalCreationManager.shared.goalBudget
        if(total != goalBudget){
            amountInfo[formatDate(start)] = String(Int64(amountInfo[formatDate(start)]!)! + (goalBudget! - total))
        }
    }
    
    func presentEditModal(for date: Date, with currentAmount: Int64) {
        // Create an instance of GoalAmountModalViewController
        let goalAmountModalVC = GoalAmountModalViewController()
        
        // Configure the properties of the modal
        goalAmountModalVC.modalPresentationStyle = .pageSheet
        goalAmountModalVC.modalTransitionStyle = .coverVertical
        goalAmountModalVC.delegate = self
        goalAmountModalVC.date = date
        goalAmountModalVC.currentTotalAmount = currentAmount
        
        // Present the modal
        self.present(goalAmountModalVC, animated: true, completion: nil)
    }

    
    private func refreshAmountInfo(startDate : Date, endDate : Date) {
        
        let goalBudget = GoalCreationManager.shared.goalBudget
        let unedited = findAllTheUneditedDays()
        let editedsum = calculateEditedAmount(from: startDate, to: endDate)
        let distributingBudget = goalBudget! - editedsum
        
        if distributingBudget < 0 {
            //1/N 진행안됨.
            print("합이 너무 큼.")
        }else if distributingBudget == 0 {
            //0원 분배
            if unedited.count <= 1 { //한번씩은 다 수정이 되었다. 이제부터는 1/n 기능이 꺼진다. 이젠 금액이 넘어가는지만 체크한다.
                return
            }else{ //아직 수정이 다 안됐다. 1/N 지원!
                if (distributingBudget / Int64(unedited.count)) < 100 {
                    let distributingDays = distributingBudget/100
                    let remainder = distributingBudget%100
                    distribution(startDate: startDate, endDate: endDate, days: distributingDays, budget: 100, remainder: remainder, addToHead: false)
                }else{
                    //발생해선 안됨
                    print("error")
                }
            }
        }else{
            if unedited.count <= 1 { //한번씩은 다 수정이 되었다. 이제부터는 1/n 기능이 꺼진다.
                return
            }else{ //아직 수정이 다 안됐다. 1/N 지원!
                if (distributingBudget / Int64(unedited.count)) < 100 {
                    let distributingDays = distributingBudget/100
                    let remainder = distributingBudget%100
                    distribution(startDate: startDate, endDate: endDate, days: distributingDays, budget: 100, remainder: remainder, addToHead: false)
                }else{
                    let k = distributingBudget / Int64(unedited.count)
                    if k % 100 == 0 {
                        distribution(startDate: startDate, endDate: endDate, days: Int64(unedited.count), budget: k, remainder: 0, addToHead: true)
                    }else{
                        let remainderConstant = k%100
                        let budget = k - remainderConstant
                        let remainderMultiplier = Int64(unedited.count)
                        let remainder = remainderConstant * remainderMultiplier
                        distribution(startDate: startDate, endDate: endDate, days: Int64(unedited.count), budget: budget, remainder: remainder, addToHead: true)
                        
                    }
                }
            }
        }
    }
    
//    func distribution(startDate: Date, endDate: Date, days : Int, budget : Int, remainder : Int, addToHead : Bool){
//        var firstAdded = false
//        var lastAdded = false
//        //while문으로 startDate ~ endDate 까지 돌면서
//        //isEdited[dateKey] = false 인 곳에 budget을 넣는다.
//        //addToHead가 true일때, firstAdded가 false라면 처음 넣는 날이다. remainder + budget를 더한다. firstAdded =true. days-=1
//        //addToHead가 true일때, firstAdded가 true라면 budget를 더한다. days-=1. 마지막에 days가 0이 되면 return
//        //addToHead가 false일때, days가 0이고, lastAdded == false면, remainder를 amountInfo[dateKey] 에 할당하고,
//        //addToHead가 false일때, days가 0이고, lastAdded == true면, amountInfo[dateKey]에 0을 할당.
//    }
    
    func distribution(startDate: Date, endDate: Date, days: Int64, budget: Int64, remainder: Int64, addToHead: Bool) {
        
        var firstAdded = false
        var lastAdded = false
        var currentDate = startDate
        var daysLeft = days
        
        while currentDate <= endDate {
            let dateString = formatDate(currentDate)
            
            // isEdited[dateKey] = false 인 경우 budget 할당
            if !isEdited[dateString]! {
//                amountInfo[dateString] = "\(budget)"
//                isEdited[dateString] = true
//                daysLeft -= 1
                
                if addToHead {
                    if !firstAdded {
                        let initialBudget = remainder + budget
                        amountInfo[dateString] = "\(initialBudget)"
                        firstAdded = true
                        daysLeft -= 1
                    } else {
                        amountInfo[dateString] = "\(budget)"
                        daysLeft -= 1
                        if daysLeft == 0 {
                            return
                        }
                    }
                }else{
                    if daysLeft == 0 && !lastAdded{
                        amountInfo[dateString] = "\(remainder)"
                        lastAdded = true
                    }
                    else if daysLeft == 0 && lastAdded {
                        amountInfo[dateString] = "0"
                    }
                    else if daysLeft > 0 {
                        amountInfo[dateString] = "\(budget)"
                        daysLeft -= 1
                    }
                    
                }
            }
            
            // endDate까지 도달한 경우 (사실 이 작업 의미 없을수도)
            if currentDate == endDate {
                lastAdded = true
            }
            
            // 다음 날짜로 이동
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
    }

    func updateAmount(for date: Date, with text: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateKey = dateFormatter.string(from: date)
        
        // startDate와 endDate 사이의 날짜에 대해서만 업데이트를 허용합니다.
        if let startDate = customCalendarView.startDate, let endDate = customCalendarView.endDate,
           date >= startDate && date <= endDate {
            amountInfo[dateKey] = text
            
            // 필요한 경우 캘린더 뷰를 업데이트합니다.
            customCalendarView.calendar.reloadData()
        } else {
            print("날짜는 startDate와 endDate 사이여야 합니다.")
        }
    }
    
    func findAllTheUneditedDays() -> [String] {
        var uneditedDays: [String] = []
        // amountInfo 딕셔너리의 키들을 반복하여 uneditedDays 배열에 편집되지 않은 날짜를 추가합니다.
        for (dateKey, edited) in isEdited {
            if !edited {
                uneditedDays.append(dateKey)
            }
        }
        return uneditedDays
    }

    
    func calculateTotalAmount(from startDate: Date, to endDate: Date) -> Int64 {
        var totalAmount: Int64 = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        for (dateKey, value) in amountInfo {
            if let date = dateFormatter.date(from: dateKey) {
                // startDate와 endDate 사이의 날짜에 대해서만 계산합니다.
                if date >= startDate && date <= endDate {
                    // 금액의 문자열에서 ','를 제거하고 Int64로 변환하여 총합에 더합니다.
                    let formattedValue = value.replacingOccurrences(of: ",", with: "")
                    if let amount = Int64(formattedValue) {
                        totalAmount += amount
                    } else {
                        print("잘못된 형식의 금액입니다: \(value)")
                    }
                }
            } else {
                print("잘못된 날짜 형식입니다: \(dateKey)")
            }
        }
        
        return totalAmount
    }
    
    func calculateEditedAmount(from startDate: Date, to endDate: Date) -> Int64 {
        var totalAmount: Int64 = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        if findAllTheUneditedDays().count == 1 {
            return calculateTotalAmount(from: startDate, to: endDate)
        }
        
        for (dateKey, value) in isEdited {
            if let date = dateFormatter.date(from: dateKey) {
                // startDate와 endDate 사이의 날짜에 대해서만 계산합니다.
                if date >= startDate && date <= endDate && value {
                    // 금액의 문자열에서 ','를 제거하고 Int64로 변환하여 총합에 더합니다.
                    let formattedValue = amountInfo[dateKey]?.replacingOccurrences(of: ",", with: "") ?? "0"
                    if let amount = Int64(formattedValue) {
                        totalAmount += amount
                    } else {
                        print("잘못된 형식의 금액입니다: \(value)")
                    }
                }
            } else {
                print("잘못된 날짜 형식입니다: \(dateKey)")
            }
        }
        
        return totalAmount
    }
    
    func convertToInt64Array(from dict: [String: String]) -> [Int64] {
        var intArray: [Int64] = []
        
        for (_, value) in dict {
            // 쉼표를 제거하고 숫자로 변환하여 배열에 추가
            let numericValue = value.replacingOccurrences(of: ",", with: "")
            if let intValue = Int64(numericValue) {
                intArray.append(intValue)
            } else {
                // 숫자로 변환할 수 없는 경우 0으로 처리하거나 오류 처리
                // 여기서는 일단 0으로 처리합니다.
                intArray.append(0)
            }
        }
        
        return intArray
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
}



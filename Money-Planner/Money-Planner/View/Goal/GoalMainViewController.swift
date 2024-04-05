//
//  GoalMainViewController.swift
//  Money-Planner
//
//  Created by 유철민 on 1/17/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension GoalMainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let boundsHeight = scrollView.bounds.size.height

        if offsetY > (contentHeight - boundsHeight - 100) { // 100은 미리 로딩을 시작할 트리거 포인트
            viewModel.fetchNextPageIfPossible(){ [weak self] in
                DispatchQueue.main.async {
                   print("추가 notNowGoals 업데이트 됨")
                }
            }
        }
    }
}

//extension GoalMainViewController : GoalMainViewDelegate {
//    func didRequestToFetchMoreData() {
//        viewModel.fetchNextPageIfPossible(goalId: String(goalId)){ [weak self] in
//            DispatchQueue.main.async {
//               print("추가 소비내역 업데이트 됨")
//            }
//        }
//    }
//}

//protocol GoalMainViewDelegate: AnyObject {
//    func didRequestToFetchMoreData()
//}


class GoalMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    private let disposeBag = DisposeBag()
    private let headerView = GoalMainHeaderView()
    private let goalTable = UITableView(frame: .zero, style: .grouped)
    private let viewModel = GoalMainViewModel.shared
    
    private var nowData: Goal_? //{
//        didSet {
//            goalTable.reloadData()
//        }
    //}
    
    private var notNowData: [Goal_] = [] //{
//        didSet {
//            goalTable.reloadData()
//        }
    //}
    
    override func viewDidLoad() {
        super.viewDidLoad()

                NotificationCenter.default.addObserver(self, selector: #selector(getNotificationGoalView), name: Notification.Name("addGoal"), object: nil)
        
        view.backgroundColor = UIColor(hexCode: "F5F6FA")
        
        viewModel.nowGoal.asObservable()
            .subscribe(onNext: { [weak self] nowGoal in
                self?.nowData = nowGoal
                self?.goalTable.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.notNowGoals.asObservable()
            .skip(1) // 초기값을 스킵하고 실제 업데이트 될 때만 반응하도록 설정
            .subscribe(onNext: { [weak self] notNowGoals in
                self?.notNowData = notNowGoals
                self?.goalTable.reloadData()
            }).disposed(by: disposeBag)
//        setupSubscriptions()
        
        setupHeaderView()
        setupGoalTable()
        view.bringSubviewToFront(headerView)
        goalTable.delegate = self
        headerView.addNewGoalBtn.addTarget(self, action: #selector(addNewGoalButtonTapped), for: .touchUpInside)
        
        viewModel.fetchNowGoal()
        viewModel.fetchNotNowGoals()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
//        viewModel.fetchNowGoal()
//        viewModel.fetchNotNowGoals()
    }
    
//    func update(with nowGoal : [Goal_], with notNowGoals : [Goal_]) {
//        // selectedCategory가 비어있지 않은 경우, 선택된 카테고리에 해당하는 항목만 필터링
//        self.nowData = nowGoal
//        self.notNowData = notNowGoals
//    }
    
    private func setupSubscriptions() {
        viewModel.nowGoal.asObservable()
            .subscribe(onNext: { [weak self] nowGoal in
                self?.nowData = nowGoal
                self?.goalTable.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.notNowGoals.asObservable()
            .skip(1) // 초기값을 스킵하고 실제 업데이트 될 때만 반응하도록 설정
            .subscribe(onNext: { [weak self] notNowGoals in
                self?.notNowData = notNowGoals
                self?.goalTable.reloadData()
            }).disposed(by: disposeBag)
    }
    
    
    @objc func addNewGoalButtonTapped() {
        // Create and present GoalTitleViewController
        //탭바가 안보이도록
        self.tabBarController?.tabBar.isHidden = true
        
        let goalTitleViewController = GoalTitleViewController()
        navigationController?.pushViewController(goalTitleViewController, animated: true)
    }
    
    private func setupHeaderView() {
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 62),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50) // 설정한 헤더 높이
        ])
    }
    
    private func setupGoalTable() {
        
        view.addSubview(goalTable)
        goalTable.showsVerticalScrollIndicator = false
        goalTable.backgroundColor = UIColor(hexCode: "F5F6FA")
        goalTable.separatorStyle = .none
        goalTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goalTable.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            goalTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            goalTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            goalTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        goalTable.dataSource = self
        goalTable.delegate = self
        
        // Register the GoalPresentationCell class for the cell identifier
        goalTable.register(GoalPresentationCell.self, forCellReuseIdentifier: "GoalPresentationCell")
        goalTable.register(GoalEmptyCell.self, forCellReuseIdentifier: "GoalEmptyCell")
        
        // Set the estimated and actual section header height
        goalTable.estimatedSectionHeaderHeight = 50 // Set your estimated header height
        goalTable.sectionHeaderHeight = 40//UITableView.automaticDimension
        
    }
    
    // UITableViewDataSource 메서드
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 두 개의 섹션
    }
    
    // UITableViewDataSource 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return nowData == nil ? 1 : 1
        case 1:
            return notNowData.isEmpty ? 1 : notNowData.count
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Section for current goal
            if let nowGoal = nowData {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GoalPresentationCell", for: indexPath) as! GoalPresentationCell
                // Assuming `configureCell` takes a Goal_ instance and a Bool indicating whether it's a current goal
                cell.configureCell(with: nowGoal, isNow: true)
                return cell
            } else {
                // Show an "empty" cell if there's no current goal
                let cell = tableView.dequeueReusableCell(withIdentifier: "GoalEmptyCell", for: indexPath) as! GoalEmptyCell
                cell.configure(with: "현재 진행 중인 목표가 없습니다.\n+ 버튼을 눌러 새 목표를 생성해보세요!")
                return cell
            }
        } else if indexPath.section == 1 {
            // Section for past and future goals
            if notNowData.isEmpty {
                // Show an "empty" cell if there are no past or future goals
                let cell = tableView.dequeueReusableCell(withIdentifier: "GoalEmptyCell", for: indexPath) as! GoalEmptyCell
                cell.configure(with: "아직 지난/예정된 목표가 없습니다.")
                return cell
            } else {
                // Configure cell with goal data from notNowData
                let cell = tableView.dequeueReusableCell(withIdentifier: "GoalPresentationCell", for: indexPath) as! GoalPresentationCell
                let goal = notNowData[indexPath.row]
                cell.configureCell(with: goal, isNow: false)
                return cell
            }
        } else {
            // Return an empty UITableViewCell in case of an unexpected section
            return UITableViewCell()
        }
    }

    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            // Now Goals section
//            if let nowGoal = viewModel.nowGoalResponse.value?.result {
//                // If there is a current goal, configure and return a GoalPresentationCell
//                let cell = tableView.dequeueReusableCell(withIdentifier: "GoalPresentationCell", for: indexPath) as! GoalPresentationCell
//                cell.configureCell(with: nowGoal, isNow: true)
//                cell.btnTapped = { [weak self] in
//                    // Navigate to GoalDetailsViewController with the selected goal's details
//                    let goalDetailsVC = GoalDetailsViewController(goalID: nowGoal.goalId)
//                    self?.navigationController?.pushViewController(goalDetailsVC, animated: true)
//                    self?.tabBarController?.tabBar.isHidden = true
//                }
//                return cell
//            } else {
//                // If there are no current goals, configure and return a GoalEmptyCell
//                let cell = tableView.dequeueReusableCell(withIdentifier: "GoalEmptyCell", for: indexPath) as! GoalEmptyCell
//                cell.configure(with: "현재 진행 중인 목표가 없습니다.\n+ 버튼을 눌러 새 목표를 생성해보세요!")
//                return cell
//            }
//        } else if indexPath.section == 1 {
//            // Not Now Goals section
//            let notNowGoals = viewModel.notNowGoals.value
//            if notNowGoals.count == 0 {
//                // If there are no past or future goals, configure and return a GoalEmptyCell
//                let cell = tableView.dequeueReusableCell(withIdentifier: "GoalEmptyCell", for: indexPath) as! GoalEmptyCell
//                cell.configure(with: "아직 지난/예정된 목표가 없습니다.")
//                return cell
//            } else {
//                // If there are past or future goals, configure and return a GoalPresentationCell
//                //                let goal = notNowGoals[indexPath.row]
//                let cell = tableView.dequeueReusableCell(withIdentifier: "GoalPresentationCell", for: indexPath) as! GoalPresentationCell
//                let goal = viewModel.notNowGoals.value[indexPath.row]
//                cell.configureCell(with: goal, isNow: false)
//                return cell
//            }
//        } else {
//            // Fallback for any other section
//            return UITableViewCell()
//        }
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "진행 중인 목표"
        } else {
            return "나의 목표들"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }
    
    // section 편집용 UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear // Set the background color of the header
        
        // Create a label for the section title with your desired font
        let titleLabel = MPLabel()
        titleLabel.font = .mpFont16M() // Set your desired font
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints to position the label within the header view
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    
    // UITableViewDelegate 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 선택된 셀의 하이라이트 제거
        
        if indexPath.section == 0 {
            // 현재 진행 중인 목표 선택 처리
            if let goal = viewModel.nowGoalResponse.value?.result {
                let goalDetailsVC = GoalDetailsViewController(goalID: Int(goal.goalId))
                navigationController?.pushViewController(goalDetailsVC, animated: true)
                print("목표 자세히 보기 vc로 전환")
                print("goalID : \(goal.goalId), 이름 : \(goal.goalTitle)")
                self.tabBarController?.tabBar.isHidden = true
            }
        } else if indexPath.section == 1 {
            // 과거 혹은 미래 목표 선택 처리
            let notNowGoals = viewModel.notNowGoals.value
            
            if notNowGoals.count == 0 {
                return
            }
            
            if indexPath.row < notNowGoals.count {
                let selectedGoal = notNowGoals[indexPath.row]
                let goalDetailsVC = GoalDetailsViewController(goalID: selectedGoal.goalId)
                print("목표 자세히 보기 vc로 전환")
                print("goalID : \(selectedGoal.goalId), 이름 : \(selectedGoal.goalTitle)")
                navigationController?.pushViewController(goalDetailsVC, animated: true)
                self.tabBarController?.tabBar.isHidden = true
            }
        }
    }
    
    
    //    func onNotNowGoalsUpdated() {
    //        let currentCount = goalTable.numberOfRows(inSection: 1)
    //
    //        let newCount = viewModel.notNowGoals.value.count // 새로운 데이터의 개수
    //
    //        // 새로운 항목이 추가되었는지 확인
    //        guard newCount > currentCount else { return }
    //
    //        // 새로 추가될 셀들의 인덱스 경로를 계산
    //        var indexPaths: [IndexPath] = []
    //        for index in currentCount..<newCount {
    //            let indexPath = IndexPath(row: index, section: 1)
    //            indexPaths.append(indexPath)
    //        }
    //
    //        // 테이블 뷰 업데이트 시작
    //        goalTable.beginUpdates()
    //
    //        // 새로운 셀들을 삽입
    //        goalTable.insertRows(at: indexPaths, with: .automatic) // .automatic은 애니메이션 효과
    //
    //        // 테이블 뷰 업데이트 종료
    //        goalTable.endUpdates()
    //
    //        goalTable.reloadData()
    //    }
    
    func onNotNowGoalsUpdated() {
        let currentCount = goalTable.numberOfRows(inSection: 1)
        let newCount = viewModel.notNowGoals.value.count // 새로운 데이터의 개수
        
        let actualCount = currentCount == 1 && newCount >= 1 ? 0 : currentCount
        let difference = newCount - actualCount
        
        goalTable.beginUpdates()
        
        if difference > 0 {
            // 새로운 항목들을 삽입
            var indexPaths: [IndexPath] = []
            for index in actualCount..<newCount {
                indexPaths.append(IndexPath(row: index, section: 1))
            }
            goalTable.insertRows(at: indexPaths, with: .automatic)
        } else if difference < 0 {
            // 기존의 항목들을 제거
            var indexPaths: [IndexPath] = []
            for index in newCount..<actualCount {
                indexPaths.append(IndexPath(row: index, section: 1))
            }
            goalTable.deleteRows(at: indexPaths, with: .automatic)
        }
        
        if currentCount == 1 && newCount == 0 {
            // "없음"을 표시하는 셀을 다시 삽입
            goalTable.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        } else if currentCount == 1 && newCount > 0 {
            // "없음"을 표시하는 셀을 제거
            goalTable.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }
        
        goalTable.endUpdates()
        goalTable.reloadData()
    }
    
    
    
    @objc func getNotificationGoalView(){
        viewModel.fetchNowGoal()
        viewModel.fetchNotNowGoals()
    }
}


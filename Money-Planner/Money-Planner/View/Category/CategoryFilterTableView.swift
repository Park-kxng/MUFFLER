//
//  CategoryFilterTableView.swift
//  Money-Planner
//
//  Created by p_kxn_g on 2/1/25.
//

import UIKit

class CategoryFilterTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    let viewModel = GoalDetailViewModel.shared
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    var categoryList: [Category] = [] {
        didSet {
            // Filter categories where isVisible is true, initially assume all are not selected (false)
            filteredCategoryList = categoryList.filter { $0.isVisible ?? false }.map { ($0, false) }
            tableView.reloadData()
        }
    }
    
    var selectedKey : String = ""
    
    private var filteredCategoryList: [(Category,Bool)] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryFilterCell.self, forCellReuseIdentifier: "CategoryFilterCell")
        tableView.register(SelectAllTableViewCell.self, forCellReuseIdentifier: "SelectAllTableViewCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryFilterCell", for: indexPath) as? CategoryFilterCell else {
//            fatalError("Unable to dequeue CategoryFilterCell")
//        }
//
//        let category = filteredCategoryList[indexPath.row]
//        cell.configure(with: category)
//
//        // '모두 선택' 상태에 따라 셀의 체크박스 상태 설정
//        if isAllSelected {
//            cell.checkButton.setChecked(true)
//        }
//
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCategoryList.count + 1 // "모두 선택" 셀을 위해 +1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 맨 위의 셀인 경우 "모두 선택" 셀 구성
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAllTableViewCell", for: indexPath) as! SelectAllTableViewCell
            let allSelected = filteredCategoryList.allSatisfy { $0.1 }
            cell.checkButton.setChecked(allSelected)
            cell.onCheckButtonTapped = { [weak self] in
                let newState = !allSelected
                self?.toggleAllSelections(isSelected: newState)
            }
            return cell
        }else {
            // 기존 카테고리 셀 구성
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryFilterCell", for: indexPath) as? CategoryFilterCell else {
                fatalError("Unable to dequeue CategoryFilterCell")
            }
            
            let (category, isSelected) = filteredCategoryList[indexPath.row - 1]
            cell.configure(with: category)
            // Use isSelected to determine how to display the category, e.g., check mark visibility
            cell.checkButton.setChecked(isSelected)
        
            cell.onCheckButtonTapped = { [weak self] isChecked in
                self?.filteredCategoryList[indexPath.row - 1].1 = isChecked
                
                if(isChecked){
                    cell.iconView.layer.opacity = 1
                    cell.titleLabel.textColor = .mpBlack
                }else{
                    cell.iconView.layer.opacity = 0.4
                    cell.titleLabel.textColor = .mpGray
                }
                
                self?.updateSelectAllBasedOnIndividualSelection() // 모든 선택이 업데이트 되었는지 확인 후 "모두 선택" 셀 업데이트
            }
            
            //이 위치에만 있을때는 어째서인지, 전체 선택시만 변경됨.
            if(isSelected){
                cell.iconView.layer.opacity = 1
                cell.titleLabel.textColor = .mpBlack
            }else{
                cell.iconView.layer.opacity = 0.4
                cell.titleLabel.textColor = .mpGray
            }
            
            return cell
        }
    }
    
    // 카테고리 선택 상태를 딕셔너리로 반환하는 함수
    //    func getCategorySelections() -> [String: Bool] {
    //        var selections: [String: Bool] = [:]
    //
//        if filteredCategoryList.count != categoryList.count {
//            for i in 0..<filteredCategoryList.count {
//                if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? CategoryFilterCell {
//                    selections[filteredCategoryList[i].categoryIcon!] = cell.checkButton.isChecked
//                    selectedKey = filteredCategoryList[i].name
//                }
//            }
//        }
//
//        return selections
//    }
    
    func getCategorySelections() -> [String: Bool] {
        var selections: [String: Bool] = [:]
        
        for (category, isSelected) in filteredCategoryList {
            if let categoryID = category.categoryIcon { // Assuming categoryIcon is a unique identifier
                selections[categoryID] = isSelected
                if isSelected {
                    selectedKey = category.name
                }
            }
        }
        viewModel.selectedCategoryRelay.accept(selections)
//        print(selections)
        return selections
    }

    
    func getSelectedKey() -> String {
        return selectedKey
    }

    // 주어진 [String: Bool] 딕셔너리를 사용하여 각 셀의 isChecked 상태를 설정하는 함수
    func applySelections(_ selections: [String: Bool]) {
        var indexPathsToUpdate: [IndexPath] = []

        for (index, categoryTuple) in filteredCategoryList.enumerated() {
            if let categoryID = categoryTuple.0.categoryIcon, // Assuming categoryIcon is a unique identifier
               let isSelected = selections[categoryID] {
                if categoryTuple.1 != isSelected {
                    // 상태가 변경된 경우에만 업데이트
                    filteredCategoryList[index].1 = isSelected
                    // "모두 선택" 셀을 제외한 인덱스 업데이트
                    indexPathsToUpdate.append(IndexPath(row: index + 1, section: 0))
                }
            }
        }

        // "모두 선택" 셀의 상태도 업데이트 필요
        updateSelectAllBasedOnIndividualSelection()
        // 변경된 셀들만 업데이트
        tableView.reloadRows(at: indexPathsToUpdate, with: .none)
    }

    
    func toggleAllSelections(isSelected: Bool) {
        for index in 0..<filteredCategoryList.count {
            filteredCategoryList[index].1 = isSelected
        }
        tableView.reloadData()
    }
    
    @objc func toggleSelectAll(_ sender: CheckBtn) {
        let isSelected = sender.isChecked
        toggleAllSelections(isSelected: isSelected)
    }

    func updateSelectAllBasedOnIndividualSelection() {
        let allSelected = filteredCategoryList.allSatisfy { $0.1 }
        let selectAllIndexPath = IndexPath(row: 0, section: 0)
        if let cell = tableView.cellForRow(at: selectAllIndexPath) as? SelectAllTableViewCell {
            cell.checkButton.setChecked(allSelected)
        }
    }
    
}



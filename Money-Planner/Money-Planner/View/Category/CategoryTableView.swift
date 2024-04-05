//
//  CategoryTableView.swift
//  Money-Planner
//
//  Created by seonwoo on 2024/01/24.
//

import Foundation
import UIKit

protocol CategoryTableViewDelegate: AnyObject {
    func categoryDidSelect(at indexPath: IndexPath)
}

class CategoryTableView : UIView, AddCategoryViewDelegate{
    
    func AddCategoryCompleted(_ name: String, iconName: String) {
    }
    
    
    weak var delegate: CategoryTableViewDelegate?

    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isEditing = true
        table.allowsSelectionDuringEditing = true
        return table
    }()
    
    var categoryList : [Category] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .mpWhite
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .mpWhite
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    private func setupUI(){
        print(categoryList.count)
        backgroundColor = .mpWhite
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CategoryTableCell.self, forCellReuseIdentifier: "CategoryTableCell")
        
        self.addSubview(self.tableView)
        
        tableView.separatorInset.left = 0
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo:bottomAnchor)
        ])
    }
    
}

extension CategoryTableView : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableCell", for: indexPath) as? CategoryTableCell else {
            fatalError("Unable to dequeue CategoryTableCell")
        }
        
        let category = categoryList[indexPath.row]
        
        cell.configure(with: category)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    // 왼쪽 버튼 없애기
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
     
    // editing = true 일 때 왼쪽 버튼이 나오기 위해 들어오는 indent 없애기
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let removed = categoryList.remove(at: sourceIndexPath.row)
        categoryList.insert(removed, at: destinationIndexPath.row)
        
        updateCategoryPriorities()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at index: \(indexPath.row)")
        print(indexPath)
        delegate?.categoryDidSelect(at: indexPath)
    }
    
    func changeVisibility(forCellAt indexPath: IndexPath) {
          categoryList[indexPath.row].isVisible!.toggle()
          tableView.reloadRows(at: [indexPath], with: .automatic)
      }
    
    
    private func updateCategoryPriorities() {
        for (index, _) in categoryList.enumerated() {
            categoryList[index].priority = index + 1
        }
    }
}

class CategoryTableCell: UITableViewCell {
    
    var eyeImageView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "eye.fill")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.mpFont18M()
        label.textColor = .mpBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        // 다른 설정을 추가할 수 있습니다.
        return label
    }()
    
    let iconView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.mpDarkGray
        view.layer.cornerRadius = 16 // 동그라미의 반지름 설정
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpGesture()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpGesture()
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(eyeImageView)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            iconView.heightAnchor.constraint(equalToConstant: 32),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            eyeImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            eyeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
        ])
    }
    
    func configure(with category: Category) {
        titleLabel.text = category.name
        titleLabel.alpha = 1.0
        if let iconName = category.categoryIcon {
            iconView.image = UIImage(named: iconName)
        }
        
        if category.isVisible! {
            eyeImageView.image = UIImage(systemName: "eye.fill")
            eyeImageView.tintColor = .mpGray
            iconView.alpha = 1.0
        } else {
            eyeImageView.image = UIImage(systemName: "eye.slash.fill")
            eyeImageView.tintColor = .mpLightGray
            
            titleLabel.alpha = 0.4
            iconView.alpha = 0.4

        }
    }
    
    @objc func eyeImageViewTapped() {
        guard let superview = superview as? UITableView, let indexPath = superview.indexPath(for: self) else {
            return
        }
        
        if let categoryTableView = superview.superview as? CategoryTableView {
            categoryTableView.changeVisibility(forCellAt: indexPath)
        }
    }
    
    func setUpGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(eyeImageViewTapped))
        eyeImageView.addGestureRecognizer(tapGesture)
    }
}

class SelectAllTableViewCell: UITableViewCell {
    
    // CheckBtn 인스턴스 추가
    var checkButton: CheckBtn = {
        let button = CheckBtn()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "전체 카테고리 선택"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var onCheckButtonTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
        ])
        
        checkButton.addTarget(self, action: #selector(handleCheckButtonTap), for: .touchUpInside)
    }
    
    @objc private func handleCheckButtonTap() {
        onCheckButtonTapped?()
    }
}


class CategoryFilterCell: UITableViewCell {
    
    var onCheckButtonTapped: ((Bool) -> Void)?
    // CheckBtn 인스턴스 추가
    var checkButton: CheckBtn = {
        let button = CheckBtn()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18) // 예시 폰트
        label.textColor = .black // 예시 색상
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let iconView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .darkGray // 예시 배경색
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var titleLabelLeadingAnchorConstraint : NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkButton)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            checkButton.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            checkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
        ])
        
        titleLabelLeadingAnchorConstraint = titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12)
        titleLabelLeadingAnchorConstraint?.isActive = true
        
        checkButton.addTarget(self, action: #selector(handleCheckButtonTap), for: .touchUpInside)
    }
    
    func configure(with category: Category) {
        titleLabel.text = category.name
        // 카테고리의 isVisible 속성에 따라 checkButton의 isChecked 상태 설정
        checkButton.setChecked(category.isVisible ?? true)
        
        if let iconName = category.categoryIcon {
            iconView.image = UIImage(named: iconName)
        }
    }
    
//    func selectAllMode(){
//        iconView.isHidden = true
//        titleLabel.text = "전체 카테고리 선택"
//        titleLabelLeadingAnchorConstraint?.isActive = false
//        titleLabelLeadingAnchorConstraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
//        titleLabelLeadingAnchorConstraint?.isActive = true
//    }
    
    @objc private func handleCheckButtonTap() {
        // 클로저를 통해 버튼의 상태 전달
        onCheckButtonTapped?(checkButton.isChecked)
    }
    
}


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



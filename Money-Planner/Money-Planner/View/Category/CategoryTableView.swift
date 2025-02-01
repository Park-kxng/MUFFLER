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

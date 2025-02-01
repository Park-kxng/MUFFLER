//
//  ShowingCategorySelectionModal.swift
//  Money-Planner
//
//  Created by 유철민 on 3/21/24.
//


import Foundation
import UIKit

protocol CategoryFilterDelegate: AnyObject {
    func cancelFilter2()
    func categorySelection(checkedCategory: [String: Bool], selectedKey : String)
}

class ShowingCategorySelectionModal: UIViewController, CategoryTableViewDelegate {
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Delegate Methods
//    func deleteCategoryCompleted(categoryId: Int) {
//        categoryTableView.categoryList.removeAll { $0.id == categoryId }
//        delegate?.categorySelectionDidChange()
//    }
//    
//    func editCategoryCompleted(categoryId: Int, name: String, icon: String) {
//        if let index = categoryTableView.categoryList.firstIndex(where: { $0.id == categoryId }) {
//            categoryTableView.categoryList[index].name = name
//            categoryTableView.categoryList[index].categoryIcon = icon
//            delegate?.categorySelectionDidChange()
//        }
//    }
    
    func categoryDidSelect(at indexPath: IndexPath) {
        // Category selection action
    }
    
    // MARK: - Properties
    var categoryFilterTableView: CategoryFilterTableView = {
        let v = CategoryFilterTableView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var btmBtn : MainBottomBtn = {
        let btn = MainBottomBtn(title: "다음")
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(btmBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    var seperatingArea : UIView = {
        let v = UIView()
        v.backgroundColor = .mpGypsumGray
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let viewModel = GoalDetailViewModel.shared
    var selectedCategory : [String : Bool]?
    
    weak var delegate: CategoryFilterDelegate?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mpWhite
        
        self.navigationItem.title = "카테고리 필터링"
        
        setupUI()
        fetchCategoryList()
        categoryFilterTableView.applySelections(viewModel.selectedCategoryRelay.value)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
//        categoryFilterTableView.delegate = self
        view.addSubview(seperatingArea)
        view.addSubview(categoryFilterTableView)
        view.addSubview(btmBtn)
        
        NSLayoutConstraint.activate([
            
            seperatingArea.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            seperatingArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            seperatingArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            seperatingArea.heightAnchor.constraint(equalToConstant: 8),
            
            btmBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            btmBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            btmBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            btmBtn.heightAnchor.constraint(equalToConstant: 50),
            
            categoryFilterTableView.topAnchor.constraint(equalTo: seperatingArea.bottomAnchor),
            categoryFilterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryFilterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryFilterTableView.bottomAnchor.constraint(equalTo: btmBtn.topAnchor, constant: -10)
            
        ])
    }
    
    private func fetchCategoryList() {
        CategoryRepository.shared.getCategoryAllList { [weak self] result in
            switch result {
            case .success(let categoryList):
                self?.categoryFilterTableView.categoryList = categoryList ?? []
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func btmBtnTapped(){
        delegate?.categorySelection(checkedCategory: categoryFilterTableView.getCategorySelections(), selectedKey: categoryFilterTableView.getSelectedKey())
        navigationController?.popViewController(animated: true)
    }
    
}

//
//  CategoryFilterCell.swift
//  Money-Planner
//
//  Created by p_kxn_g on 2/1/25.
//

import UIKit

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

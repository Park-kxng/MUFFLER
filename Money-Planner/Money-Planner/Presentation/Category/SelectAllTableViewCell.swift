//
//  SelectAllTableViewCell.swift
//  Money-Planner
//
//  Created by p_kxn_g on 2/1/25.
//

import UIKit

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

//
//  CategoryTableCell.swift
//  Money-Planner
//
//  Created by p_kxn_g on 2/1/25.
//

import UIKit

/// 카테고리 편집 테이블의 셀
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

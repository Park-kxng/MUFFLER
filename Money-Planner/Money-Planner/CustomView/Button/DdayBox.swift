//
//  DdayBox.swift
//  Money-Planner
//
//  Created by seonwoo on 5/3/24.
//

import Foundation
import UIKit

class DdayBox: UIView {
    var delegate : CategoryButtonDelegate?
    
    var textLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.mpWhite
        label.textAlignment = .center
        label.font = UIFont.mpFont12M()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        // UIView의 기본적인 설정
        layer.cornerRadius = 6
        
        stackView.addArrangedSubview(textLabel)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // StackView의 제약 설정
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }
}

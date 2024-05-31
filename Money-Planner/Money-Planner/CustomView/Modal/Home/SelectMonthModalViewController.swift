//
//  SelectMonthModalViewController.swift
//  Money-Planner
//
//  Created by seonwoo on 5/24/24.
//

import Foundation
import UIKit

struct SelectDate {
    let year : Int
    let month : Int
    var stringDate : String {
        return "\(year)년 \(month)월"
    }
}

protocol SelectModalDelegate : AnyObject {
    func changeDate(year : Int, month : Int)
}

class SelectModalViewController : UIViewController {
    
    var delegate : SelectModalDelegate?
    
    private let titleLabel : MPLabel = {
        let label = MPLabel()
        label.text = "어느 날짜로 이동할까요?"
        label.font = .mpFont20B()
        label.textColor = .mpBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let customModal: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.layer.borderColor = UIColor.mpMainColor.cgColor
        button.setTitleColor(.mpMainColor, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.backgroundColor = UIColor.mpMainColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    // 2024년부터 100년
    private var years : Int = 100
    private var months  : Int = 12
    lazy var selectableDate : [SelectDate] = []
    
    var currentYear : Int = -1
    var currentMonth : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        setSelectableDate()
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        view.addSubview(customModal)
        customModal.addSubview(pickerView)
        customModal.addSubview(titleLabel)
        customModal.addSubview(cancelButton)
        customModal.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            customModal.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customModal.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -36),
            customModal.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64),
            customModal.heightAnchor.constraint(equalToConstant: 343),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: customModal.topAnchor, constant: 36),
            
            cancelButton.bottomAnchor.constraint(equalTo: customModal.bottomAnchor, constant: -20),
            cancelButton.leadingAnchor.constraint(equalTo: customModal.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: customModal.centerXAnchor, constant: -4),
            cancelButton.heightAnchor.constraint(equalToConstant: 56),
            
            doneButton.leadingAnchor.constraint(equalTo: customModal.centerXAnchor, constant: 4),
            doneButton.bottomAnchor.constraint(equalTo: customModal.bottomAnchor, constant: -20),
            doneButton.trailingAnchor.constraint(equalTo: customModal.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 56),
            
            pickerView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 24),
            pickerView.leadingAnchor.constraint(equalTo: customModal.leadingAnchor, constant: 20),
            pickerView.trailingAnchor.constraint(equalTo: customModal.trailingAnchor, constant: -20),
            pickerView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -32)
            
        ])
    }
    
    private func setSelectableDate(){
        var selectedIndex : Int = 0
        var count = 0
        
        for i in 0...years-1 {
            for j in 1...months{
                selectableDate.append(SelectDate(year: 2023 + i, month: j))
                if(currentYear == 2023 + i && currentMonth == j){
                    selectedIndex = count
                }
                count = count + 1
            }
        }
        
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonTapped() {
        let selectRowIndex = pickerView.selectedRow(inComponent: 0)
        
        delegate?.changeDate(year: selectableDate[selectRowIndex].year, month: selectableDate[selectRowIndex].month)
        dismiss(animated: true, completion: nil)
    }
    
}

extension SelectModalViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectableDate.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectableDate[row].stringDate
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont.mpFont20R()
        label.text =  selectableDate[row].stringDate
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}


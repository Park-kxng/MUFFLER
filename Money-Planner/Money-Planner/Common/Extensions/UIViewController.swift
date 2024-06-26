//
//  UIViewController.swift
//  Money-Planner
//
//  Created by p_kxn_g on 4/5/24.
//

import Foundation
import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String, buttonTitle: String = "확인") {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    // 로딩화면 보여주기
    func showLoading() {
            let loadingView = UIView(frame: self.view.bounds)
            loadingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            loadingView.tag = 999
            
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = loadingView.center
            activityIndicator.startAnimating()
            
            loadingView.addSubview(activityIndicator)
            self.view.addSubview(loadingView)
        }
    
    // 로딩화면 취소하기
    func hideLoading() {
        if let loadingView = self.view.viewWithTag(999) {
            loadingView.removeFromSuperview()
        }
    }
}

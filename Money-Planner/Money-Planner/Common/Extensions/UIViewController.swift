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
}

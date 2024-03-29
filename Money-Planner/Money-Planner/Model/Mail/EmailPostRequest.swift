//
//  EmailResponse.swift
//  Money-Planner
//
//  Created by p_kxn_g on 3/29/24.
//

import Foundation

struct EmailPostRequest: Codable {
    let email: String
    let content: String
}

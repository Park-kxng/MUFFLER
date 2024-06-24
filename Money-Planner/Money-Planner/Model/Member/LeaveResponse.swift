//
//  LeaveResponse.swift
//  Money-Planner
//
//  Created by p_kxn_g on 6/24/24.
//

import Foundation

struct LeaveResponse: Codable {
    let isSuccess: Bool
    let message: String
    let result: ResultType?

    struct ResultType: Codable {
        
    }


    private enum CodingKeys: String, CodingKey {
        case isSuccess
        case message
        case result
    }
}

//
//  AuthenticatedAPI.swift
//  Money-Planner
//
//  Created by p_kxn_g on 4/5/24.
//

import Foundation

protocol AuthenticatedAPI {
    var requiresAuthentication: Bool { get }
}

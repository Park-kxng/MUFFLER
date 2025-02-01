//
//  Category.swift
//  Money-Planner
//
//  Created by seonwoo on 2024/01/21.
//

import Foundation

// MARK: - Category
struct Category: Codable, Hashable{
    let id: Int
    var categoryIcon : String?
    var name: String
    var priority : Int?
    var categoryBudget: Int64?
    var categoryTotalCost: Int64?
    var isVisible : Bool?
    var type : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "categoryId"
        case categoryIcon = "icon"
        case name, priority, isVisible, type, categoryBudget, categoryTotalCost
        
    }
}

struct CategoryList : Codable {
    let categories : [Category]?
}

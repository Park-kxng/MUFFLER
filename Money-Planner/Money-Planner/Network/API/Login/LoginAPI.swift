//
//  LoginAPI.swift
//  Money-Planner
//
//  Created by p_kxn_g on 3/7/24.
//

import Foundation
import Moya

enum LoginAPI {
    // Member Controller
    case refreshToken( refreshToken : RefreshTokenRequest)
    case login (request : LoginRequest)
    case join (request : JoinRequest)
    case connect

}

extension LoginAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://muffler.world")!
    }
    
    var path: String {
        switch self {
            // Member Controller
        case .refreshToken:
            return "/api/member/refresh-token"
        case .login:
            return "/api/member/login"
        case .join:
            return "/api/member/join"
        case .connect:
            return "/api/member/connect"
        }
    }
    
    var method: Moya.Method {
        switch self {
        // Define HTTP methods for each API endpoint
        case .refreshToken,.login:
            return .post
        case .join:
            return .patch
        case .connect:
            return .get
        }
    }
    
    // Define request parameters for each API endpoint
    var task: Task {
        switch self {
        case  .connect:
            return .requestPlain
        case .join(let request):
            return .requestJSONEncodable(request)
        case .login(let request):
            return .requestJSONEncodable(request)
        case .refreshToken(let refreshTokenRequest):
            return .requestJSONEncodable(refreshTokenRequest)
            
        }
        
    }
    
    // Define sample data for each API endpoint
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        switch self {
        case .refreshToken, .login:
            return nil
        default:
            // Add access token to headers
            if let accessToken = TokenManager.shared.accessToken {
                return ["Authorization": "Bearer \(accessToken)"]
            } else {
                return nil
            }
        }
    }
}


extension LoginAPI: AuthenticatedAPI {
    var requiresAuthentication: Bool {
        switch self {
        case .join, .login, .refreshToken, .connect:
            return false
        default:
            return true
        }
    }
}

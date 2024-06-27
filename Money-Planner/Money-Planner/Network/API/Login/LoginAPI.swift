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
    case leave (request : LeaveRequest)
    case connect

}

extension LoginAPI: TargetType {
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var baseURL: URL {
        if let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String,
           let baseURL = URL(string: "https://" + baseURLString) {
            return baseURL
        } else {
            fatalError("Invalid or missing BaseURL in Info.plist")
        }
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
        case .leave:
            return "/api/member/leave"
        }
    }
    
    var method: Moya.Method {
        switch self {
        // Define HTTP methods for each API endpoint
        case .refreshToken,.login, .leave:
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
        
        case .leave(let request):
                  return .requestJSONEncodable(request)
                
            
        }
        
    }
    
    // Define sample data for each API endpoint
    var sampleData: Data {
        return Data()
    }
    
    
}


extension LoginAPI: AuthenticatedAPI {
    var requiresAuthentication: Bool {
        switch self {
        case .login, .refreshToken:
            return false
        default:
            return true
        }
    }
}

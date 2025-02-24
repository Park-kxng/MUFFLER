import Foundation
import Moya

enum RoutineAPI  {
    case getRoutineList
}

extension RoutineAPI : BaseAPI {
    
    // request 데이터 제작(요청 파라미터 제작)
    public var task: Task {
        switch self {
        case .getRoutineList:
            return .requestPlain
        }
    }
    
    public var method: Moya.Method {
        // 파라미터값을 통신요청 타입을 제작
        switch self {
        case .getRoutineList:
            return .get
        }
    }
    
    public var path : String {
        switch self {
        case .getRoutineList:
            return "/api/routine"
        }
    }
    
    public var headers: [String : String]? {
           return ["Content-type": "application/json"]
    }
}

extension RoutineAPI : AuthenticatedAPI {
    var requiresAuthentication: Bool {
        return true
    }
}

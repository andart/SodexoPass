//
//  API.swift
//  SodexoPass
//
//  Created by Andrey Artemenko on 13/04/2017.
//  Copyright © 2017 Andrey Artemenko. All rights reserved.
//

import Foundation
import Alamofire

let baseUrl = "https://restaurantpass.gift-cards.ru"

enum RequestObject {
    case balancePath
    case captchaPath
    
    var path: String {
        switch self {
        case .balancePath:
            return "/balance"
        case .captchaPath:
            return "/captcha?1492070107803"
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .balancePath:
            return nil
        case .captchaPath:
            return ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36"]
        }
    }
    
    var method: HTTPMethod {
        return HTTPMethod.get
    }
    
    var url: String {
        return baseUrl + self.path
    }
}

class API {
    
    static let shared = API()
    var cookie: HTTPCookie?
    
    func request(_ requestObject: RequestObject, parameters: Parameters?, completion: @escaping (DefaultDataResponse) -> Void) {
        Alamofire.request(requestObject.url, method: requestObject.method, parameters: parameters, encoding: JSONEncoding.default, headers: requestObject.headers).response { (dataResponse) in
            completion(dataResponse)
        }
    }
    
    func getCookie(completion: @escaping (Void) -> Void) {
        self.request(RequestObject.balancePath, parameters: nil) { dataResponse in
            if let headerFields = dataResponse.response?.allHeaderFields as? [String: String], let URL = dataResponse.response?.url
            {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL, mainDocumentURL: nil)
                completion()
            }
            
        }
    }
    
    func getCaptcha(completion: @escaping (UIImage?) -> Void) {
        self.request(RequestObject.captchaPath, parameters: nil) { (dataResponse) in
            if dataResponse.error == nil {
                completion(UIImage(data: dataResponse.data!))
            }
            else {
                completion(nil)
            }
        }
    }
    
}

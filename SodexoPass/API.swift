//
//  API.swift
//  SodexoPass
//
//  Created by Andrey Artemenko on 13/04/2017.
//  Copyright © 2017 Andrey Artemenko. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let baseUrl = "https://restaurantpass.gift-cards.ru"

enum RequestObject {
    case initPath
    case balancePath
    case captchaPath
    
    var path: String {
        switch self {
        case .initPath:
            return "/balance"
        case .balancePath:
            return "/balance"
        case .captchaPath:
            return "/captcha?1492070107803"
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .initPath:
            return nil
        case .balancePath:
            return [
                "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36",
                "Content-Type" : "application/x-www-form-urlencoded",
                "Accept" : "application/json, text/plain, */*",
                "Host" : "restaurantpass.gift-cards.ru",
                "Origin" : "https://restaurantpass.gift-cards.ru",
                "Referer" : "https://restaurantpass.gift-cards.ru/balance",
            ]
        case .captchaPath:
            return ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36"]
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .initPath, .captchaPath:
            return .get
        case .balancePath:
            return .post
        }
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
        self.request(RequestObject.initPath, parameters: nil) { dataResponse in
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
    
    func checkBalance(cardNumber: String, captchaCode: String) {
        self.request(RequestObject.balancePath, parameters: ["ean": cardNumber, "captcha": captchaCode]) { (dataResponse) in
            let json = JSON(data: dataResponse.data!)
            print("")
//            NSString(data: dataResponse.data, encoding:String.Encoding.utf8)
        }
    }
    
}

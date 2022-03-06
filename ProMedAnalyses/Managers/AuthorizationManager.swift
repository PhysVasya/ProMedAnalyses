//
//  AuthorizationManager.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 05.03.2022.
//

import Foundation


class AuthorizationManager {
    
    enum AuthorizationError: String, Error {
        case errorGettingNewSessionID = "Error getting new session ID"
        case errorGettingIoCookie = "Error getting io cookie"
        case errorGettingJSsessionID = "Error getting jSession ID"
        case emptyLoginCredentials = "Error. Seems like some of needed fields are empty."
    }
    
    static let shared = AuthorizationManager()
    
    private init () {}
    
    private var isSignedIn: Bool? {
        return UserDefaults.standard.bool(forKey: "signedInSuccessfully")
    }
    
    public var sessionID: String? {
        return UserDefaults.standard.string(forKey: "phpSessionID")
    }
    
    public var jSessionID: String? {
        return UserDefaults.standard.string(forKey: "jSessionID")
    }
    
    public var ioCookie: String? {
        return UserDefaults.standard.string(forKey: "ioCookie")
    }
    
    public var login: String? {
        return UserDefaults.standard.string(forKey: "login")
    }
    
    private func getNewSessionID (with login: String?, and password: String?, completionHandler: @escaping (Bool) -> Void) {
        
        guard let sessionID = sessionID, let login = login, let password = password else {
            print(AuthorizationError.errorGettingNewSessionID.rawValue)
            completionHandler(false)
            return
        }
        
        let url : URL = {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.path = "crimea.promedweb.ru"
            urlComponents.queryItems = [
                URLQueryItem(name: "c", value: "main"),
                URLQueryItem(name: "m", value: "index"),
                URLQueryItem(name: "method", value: "Logon"),
                URLQueryItem(name: "login", value: "inf1")
            ]
            return urlComponents.url!
        }()
        
        let request : URLRequest = {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "Host" : "crimea.promedweb.ru",
                "X-Requested-With" : "XMLHttpRequest",
                "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15",
                "Cookie" : "\(sessionID)",
                "Content-Length" : "51",
                "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "Accept-Language": "en-GB,en;q=0.9",
                "Accept-Encoding": "gzip, deflate, br",
                "Connection": "keep-alive",
                "Referer" : "https://crimea.promedweb.ru/?c=portal&m=udp",
                "Origin" : "https://crimea.promedweb.ru"
            ]
            
            request.httpBody = "login=\(login)&psw=\(password)&swUserRegion=&swUserDBType=".data(using: .utf8)
            return request
        }()
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil, let response = response else {
                print(AuthorizationError.errorGettingNewSessionID.rawValue)
                print("Error getting phpSessionID: \(error?.localizedDescription ?? "")")
                completionHandler(false)
                return
            }
            
            guard let responseURL = response.url,
                  let httpResponse = response as? HTTPURLResponse,
                  let fields = httpResponse.allHeaderFields as? [String : String]
            else {
                print(AuthorizationError.errorGettingNewSessionID.rawValue)
                completionHandler(false)
                return
            }
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: responseURL)
            for cookie in cookies {
                var cookieProperties = [HTTPCookiePropertyKey : Any]()
                cookieProperties[.value] = cookie.value
                if let newPhpSessionID = cookieProperties[.value] as? String {
                    UserDefaults.standard.set(newPhpSessionID, forKey: "phpSessionID")
                    completionHandler(true)
                }
            }
            
        }.resume()
    }
    
    private func getIoCookie (completionHanlder: @escaping (Bool) -> Void) {
        
        guard let url = URL(string: "https://crimea.promedweb.ru:9991/socket.io/?EIO=3&transport=polling&t=1644374548290-0") else {
            print(AuthorizationError.errorGettingIoCookie.rawValue)
            completionHanlder(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(AuthorizationError.errorGettingIoCookie.rawValue)
                print("Error fetching cookie: \(String(describing: error))")
                completionHanlder(false)
                return
            }
            
            guard let urlResponse = response?.url,
                  let httpResponse = response as? HTTPURLResponse,
                  let fields = httpResponse.allHeaderFields as? [String : String] else {
                      print(AuthorizationError.errorGettingIoCookie.rawValue)
                      completionHanlder(false)
                      return
                  }
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: urlResponse)
            for cookie in cookies {
                var cookieProps = [HTTPCookiePropertyKey : Any]()
                cookieProps[.value] = cookie.value
                if let receivedIoCookie = cookieProps[.value] as? String {
                    UserDefaults.standard.set(receivedIoCookie, forKey: "ioCookie")
                    completionHanlder(true)
                }
            }
        }.resume()
    }
    
    private func getJSessionID (completionHandler: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://crimea.promedweb.ru/ermp/servlets/dispatch.servlet"),
              let login = login,
              let sessionID = sessionID else {
                  print(AuthorizationError.errorGettingJSsessionID.rawValue)
                  completionHandler(false)
                  return
              }
        
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request : URLRequest = {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.allHTTPHeaderFields = [
                "Host" : "crimea.promedweb.ru",
                "X-GWT-Module-Base" : "https://crimea.promedweb.ru/ermp/",
                "X-GWT-Permutation" : "F259753E77F5103A29446CBF8D50B35D",
                "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15",
                "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "Accept-Language": "en-GB,en;q=0.9",
                "Accept-Encoding": "gzip, deflate, br",
                "Connection": "keep-alive",
                "Content-Length" : "332",
                "Cookie" : "login=\(login); PHPSESSID=\(sessionID)",
                "Content-Type" : "text/x-gwt-rpc; charset=utf-8"
            ]
            
            let reqBody = "7|0|8|https://crimea.promedweb.ru/ermp/|3B6879FB4BFF9BC66C290EC9E5A380CE|ru.persis.ermp.shared.services.InternalService|execute|ru.persis.ermp.shared.services.ICommand|ru.persis.ermp.shared.commands.LoadListCommand/1029843570|ru.persis.ermp.shared.commands.Specifier/1461100279|\(sessionID)|1|2|3|4|1|5|6|0|0|A|7|49|8|"
            req.httpBody = reqBody.data(using: .utf8)
            return req
        }()
        
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(AuthorizationError.errorGettingJSsessionID.rawValue)
                print("Error getting JSessionID: \(String(describing: error))")
                completionHandler(false)
                return
            }
            
            guard let urlResponse = response?.url,
                  let httpResponse = response as? HTTPURLResponse,
                  let fields = httpResponse.allHeaderFields as? [String : String] else {
                      print(AuthorizationError.errorGettingJSsessionID.rawValue)
                      completionHandler(false)
                      return
                  }
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: urlResponse)
            for cookie in cookies {
                var cookieProps = [HTTPCookiePropertyKey : Any]()
                cookieProps[.value] = cookie.value
                if let jSessionID = cookieProps[.value] as? String {
                    UserDefaults.standard.set(jSessionID, forKey: "jSessionID")
                    completionHandler(true)
                }
            }
        }.resume()
    }
    
    
    public func authorize (login: String?, password: String?, completion: @escaping (Bool) -> Void) {
        guard let login = login, let password = password else {
            print(AuthorizationError.emptyLoginCredentials.rawValue)
            completion(false)
            return
        }
        UserDefaults.standard.set(login, forKey: "login")
        UserDefaults.standard.set(password, forKey: "password")
        
        getNewSessionID(with: login, and: password) { [weak self] success in
            switch success {
            case true:
                self?.getIoCookie { success in
                    switch success {
                    case true:
                        self?.getJSessionID { success in
                            switch success {
                            case true:
                                completion(true)
                                UserDefaults.standard.set(true, forKey: "signedInSuccessfully")
                            case false:
                                UserDefaults.standard.set(false, forKey: "signedInSuccessfully")
                                completion(false)
                            }
                        }
                    case false:
                        UserDefaults.standard.set(false, forKey: "signedInSuccessfully")
                        completion(false)
                    }
                }
            case false:
                UserDefaults.standard.set(false, forKey: "signedInSuccessfully")
                completion(false)
            }
        }
    }
    
}

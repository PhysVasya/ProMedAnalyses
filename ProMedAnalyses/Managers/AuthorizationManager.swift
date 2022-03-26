//
//  AuthorizationManager.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 05.03.2022.
//

import Foundation

//The name basically tells what this struct is all about. Contains all of the methods needed to correctly sign. All of those are triggered when the central button on authorizationVC is tapped.

//Used through a singleton because no other cases needed

struct AuthorizationManager {
    
    enum AuthorizationError: Error, LocalizedError {
        case errorGettingNewSessionID(Error? = nil)
        case errorGettingIoCookie(Error? = nil)
        case errorGettingJSsessionID(Error? = nil)
        case emptyLoginCredentials
        
        public var errorDescription: String? {
            switch self {
            case .errorGettingNewSessionID(let error):
                return "Error getting new session ID : \(String(describing: error))"
            case .errorGettingIoCookie(let error):
                return "Error getting io cookie : \(String(describing: error))"
            case .errorGettingJSsessionID(let error):
                return "Error getting jSession ID : \(String(describing: error))"
            case .emptyLoginCredentials:
                return "Error. Seems like some of needed fields are empty."
            }
        }
    }
    
    static let shared = AuthorizationManager()
    
    //Initializer is privatized for the struct to bbe unable to init it anywhere else except using singleton.
    
    private init () {}
    
    private var isSignedIn: Bool? {
        return UserDefaults.standard.bool(forKey: "signedInSuccessfully")
    }
    
    //These 4 strings are needed for all of the async methods to run later. By those server checks whether the user is logged in.
    
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
    
    
    
    //Basically the first POST request needed to replace old phpSessionID by the new one.
    private func getNewSessionID (with login: String?, and password: String?) async throws -> Bool {
        
        guard let sessionID = sessionID, let login1 = login, let password1 = password else {
            
            //Errors are not handled properly. Need to rewrite and exclude optionals.
            throw AuthorizationError.errorGettingNewSessionID()
        }
        
        let url : URL = {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.path = "crimea.promedweb.ru"
            urlComponents.queryItems = [
                URLQueryItem(name: "c", value: "main"),
                URLQueryItem(name: "m", value: "index"),
                URLQueryItem(name: "method", value: "Logon"),
                URLQueryItem(name: "login", value: "\(login1)")
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
            
            request.httpBody = "login=\(login1)&psw=\(password1)&swUserRegion=&swUserDBType=".data(using: .utf8)
            return request
        }()
        
        return await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: request) { _, response, error in
                guard error == nil, let response1 = response else {
                    print(AuthorizationError.errorGettingNewSessionID(error).localizedDescription)
                    continuation.resume(returning: false)
                    return
                }
                do {
                    try response1.getCookie(completion: { newPhpSessionID in
                        UserDefaults.standard.set(newPhpSessionID, forKey: "phpSessionID")
                        continuation.resume(returning: true)
                    })
                } catch {
                    print(AuthorizationError.errorGettingNewSessionID(error))
                }
            }.resume()
        }
    }
    
    //Have no idea what this does, but the result of it presented as an IOCookie is needed for the latter requests.
    private func getIoCookie () async -> Bool {
        
        let url = URL(string: "https://crimea.promedweb.ru:9991/socket.io/?EIO=3&transport=polling&t=1644374548290-0")!
        
        return await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil, let response1 = response else {
                    continuation.resume(returning: false)
                    return
                }
                do {
                    try response1.getCookie(completion: { ioCookie in
                        UserDefaults.standard.set(ioCookie, forKey: "ioCookie")
                        continuation.resume(returning: true)
                    })
                } catch {
                    print(AuthorizationError.errorGettingIoCookie(error))
                }
            }.resume()
        }
    }
    
    //Same thing here. No idea what this request does, but the cookie is also needed for latter.
    private func getJSessionID () async -> Bool {
        guard let url = URL(string: "https://crimea.promedweb.ru/ermp/servlets/dispatch.servlet"),
              let login = login,
              let sessionID = sessionID else {
            print(AuthorizationError.errorGettingJSsessionID().localizedDescription)
            return false
        }
        
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
        
        return await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data1, response, error in
                guard error == nil, let response1 = response else {
                    print(AuthorizationError.errorGettingJSsessionID(error).localizedDescription)
                    continuation.resume(returning: false)
                    return
                }
                do {
                    try response1.getCookie(completion: { jSessionID in
                        UserDefaults.standard.set(jSessionID, forKey: "jSessionID")
                        continuation.resume(returning: true)
                    })
                } catch {
                    print(AuthorizationError.errorGettingJSsessionID(error))
                }
            }.resume()
        }
    }
    
    //NOT an async function because I don't know why. Just using ealrier style.
    
    public func authorize (login: String?, password: String?, completion: @escaping (Bool) -> Void) {
        guard let login = login, let password = password else {
            print(AuthorizationError.emptyLoginCredentials.localizedDescription)
            completion(false)
            return
        }
        UserDefaults.standard.set(login, forKey: "login")
        UserDefaults.standard.set(password, forKey: "password")
        
        Task {
            let successGettingSessionID = try await getNewSessionID(with: login, and: password)
            if successGettingSessionID {
                let successGettingIOCookie = await getIoCookie()
                if successGettingIOCookie {
                    let successGettingJSessionID = await getJSessionID()
                    if successGettingJSessionID {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    
    public func logout () {
        
        let url : URL = {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.queryItems = [
                URLQueryItem(name: "c", value: "main"),
                URLQueryItem(name: "m", value: "Logout")
            ]
            urlComponents.path = "crimea.promedweb.ru"
            
            return urlComponents.url!
        }()
        
        guard let io = AuthorizationManager.shared.ioCookie,
              let jSessionID = AuthorizationManager.shared.jSessionID,
              let phpSessionID = AuthorizationManager.shared.sessionID,
              let login = login else {
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Origin" : "https://crimea.promedweb.ru",
            "Referer" : "https://crimea.promedweb.ru/?c=promed",
            "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15",
            "Host":"crimea.promedweb.ru",
            "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-GB,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive",
            "X-Requested-With" : "XMLHttpRequest",
            "Content-Length" : "260",
            "Cookie" : "io=\(io); JSESSIONID=\(jSessionID); login=\(login); PHPSESSID=\(phpSessionID)"
        ]
        
        URLSession.shared.dataTask(with: request).resume()
    }
    
    
}



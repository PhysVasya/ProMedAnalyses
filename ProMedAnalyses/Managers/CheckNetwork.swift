//
//  NetworkConnectivity.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 18.02.2022.
//

import Foundation
import Network

// A class used to check whether a user uses a required interface type and has access to remote servers of promedweb.ru. Unfortunately, those can be accessed only from secure local network at hospital, where РИАМС ПроМед is used.

// The struct behaviour is pretty straightforward: Just checks the wifi interface type and sends a request to promedweb.ru server just to ping and recieve phpSessionID cookie, which later is being used to authencicate properly. The code runs at launch and the result can be seen on authentication page after running and app.
//Used through a singleton because no other cases needed


struct CheckNetwork {
    
    enum CheckingNetworkError: Error, LocalizedError {
        case wrongInterfaceType
        case noConnection
        case noCookie
        case unknown(Error)
        
        public var errorDescription: String? {
            switch self {
            case .wrongInterfaceType:
                return "In order to fetch request should be connected to wifi."
            case .noConnection:
                return "Can't reach the promed.ru server."
            case .noCookie:
                return "No cookie returned."
            case .unknown(let error):
                return "Error : \(error)"
            }
        }
    }
    
    static let shared = CheckNetwork(requiredInterfaceType: .wifi)
    private let monitor: NWPathMonitor!
    private let queue = DispatchQueue(label: "Monitor")
    
    //Initializer is privatized for the struct to bbe unable to init it anywhere else except using singleton.
        
    private init(requiredInterfaceType: NWInterface.InterfaceType) {
        monitor = NWPathMonitor(requiredInterfaceType: requiredInterfaceType)
    }
    
    public func startMonitoring () {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                checkConnection()
            } else {
                print(CheckingNetworkError.wrongInterfaceType.localizedDescription)
            }
            
        }
    }
    
    //Not using for now.
    public func stopMonitoring () {
        monitor.cancel()
    }
    
    private func checkConnection () {
        
        let url = URL(string: "https://crimea.promedweb.ru/?c=portal&m=udp")
        var request = URLRequest(url: url!)
        let sessionconfig = URLSessionConfiguration.default
        sessionconfig.timeoutIntervalForResource = 5
        
        let session = URLSession(configuration: sessionconfig)
        
        request.allHTTPHeaderFields = [
            "Host":"crimea.promedweb.ru",
            "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-GB,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive"
        ]
        request.httpMethod = "GET"
                
        session.dataTask(with: request) { _, response, er in
               guard er == nil,
                  let response = response,
                  let urlResponse = response.url,
                  let httpResponse = response as? HTTPURLResponse,
                  let fields = httpResponse.allHeaderFields as? [String : String] else {
                   
                   //In all of the error and success cases, send notification to lauchScreen made in swiftUI to change behaviour.
                   
                   NotificationCenter.default.post(name: Notification.Name("ConnectionChecked"), object: nil)

                   print(CheckingNetworkError.noConnection.localizedDescription)
                return
            }
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: urlResponse)
            for cookie in cookies {
                var cookieProps = [HTTPCookiePropertyKey : Any]()
                cookieProps[.value] = cookie.value
                guard let phpSessionID = cookieProps[.value] as? String else {
                    return
                }
                if phpSessionID == "" {
                    //We don't need an empty string for the phpSessionID to properly send authentication request later.
                    print(CheckingNetworkError.noCookie.localizedDescription)
                } else {
                    //Successful connection established only here, in which caes just save the ID in the UserDefaults.
                    NotificationCenter.default.post(name: Notification.Name("ConnectionChecked"), object: nil)
                    cachePhpSessionID(id: phpSessionID)
                }
            }
        }.resume()
    }
    
    private func cachePhpSessionID (id: String) {
        UserDefaults.standard.set(id, forKey: "phpSessionID")

    }
}





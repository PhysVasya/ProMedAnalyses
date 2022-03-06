//
//  NetworkConnectivity.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 18.02.2022.
//

import Foundation
import Network

class CheckNetwork {
    
    static let shared = CheckNetwork(requiredInterfaceType: .wifi)
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue.global()
    
    private init(requiredInterfaceType: NWInterface.InterfaceType) {
        monitor = NWPathMonitor(requiredInterfaceType: requiredInterfaceType)
    }
    
    public func startMonitoring (_ completionHandler: @escaping (_ isSatisfied: Bool, _ receivedPhpSessIdCookie: String?)->Void) {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] _ in
            self?.checkConnection { result in
                switch result {
                case .success(let phpSessionID):
                    completionHandler(true, phpSessionID)
                case .failure(let error):
                    completionHandler(false, error.localizedDescription)
                }
            }
        }
    }
    
    public func stopMonitoring () {
        monitor.cancel()
    }
    
    enum ConnectionError: String, Error {
        case noConnection = "Could not connect to the server."
        case noCookie = "Received no cookie."
    }
    
    private func checkConnection (_ completionHandler: @escaping (Result<String?, Error>) -> Void) {
        let url = URL(string: "https://crimea.promedweb.ru/?c=portal&m=udp")
        var request = URLRequest(url: url!)
        let sessionconfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionconfig)
        
        request.allHTTPHeaderFields = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15",
            "Host":"crimea.promedweb.ru",
            "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-GB,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive"
        ]
        
        session.dataTask(with: request) { [weak self] _, response, er in
            guard er == nil else {
                completionHandler(.failure(ConnectionError.noConnection))
                return
            }
    
            guard let response = response,
                  let urlResponse = response.url,
                  let httpResponse = response as? HTTPURLResponse,
                  let fields = httpResponse.allHeaderFields as? [String : String] else {
                      completionHandler(.failure(ConnectionError.noConnection))
                      return
                  }
        
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: urlResponse)
            for cookie in cookies {
                var cookieProps = [HTTPCookiePropertyKey : Any]()
                cookieProps[.value] = cookie.value
                guard let phpSessionID = cookieProps[.value] as? String else {
                    completionHandler(.failure(ConnectionError.noCookie))
                    return
                }
                self?.cachePhpSessionID(id: phpSessionID)
                completionHandler(.success(phpSessionID))
            }
        }.resume()
    }
    
    private func cachePhpSessionID (id: String) {
        UserDefaults.standard.set(id, forKey: "phpSessionID")
    }
}

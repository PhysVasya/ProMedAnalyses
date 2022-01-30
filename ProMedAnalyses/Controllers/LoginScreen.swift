//
//  LoginScreen.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 28.01.2022.
//

import Foundation
import UIKit
import WebKit

class LoginScreen: UIViewController, WKUIDelegate {
    
    let webView : WKWebView = {
        let config = WKWebViewConfiguration()
        let vw = WKWebView(frame: .zero, configuration: config)
        
        return vw
    }()
    
    let url = URL(string: "https://crimea.promedweb.ru/?c=portal&m=udp")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = view.bounds
        webView.load(URLRequest(url: url!))
        view.addSubview(webView)
        webView.uiDelegate = self

    }
    
}

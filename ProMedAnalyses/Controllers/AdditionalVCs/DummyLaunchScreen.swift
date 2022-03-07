//
//  DummyLaunchScreen.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 05.03.2022.
//

import UIKit

class DummyLaunchScreen: UIViewController {
    
    static let identifier = "DummyLaunchScreen"
    
    
    let loadingIndicator = UIActivityIndicatorView()
    
    var isConnected : Bool? {
         return (UIApplication.shared.delegate as! AppDelegate).connectionIsSatisfied ?? false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loadingIndicator)
        loadingIndicator.style = .large
        loadingIndicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingIndicator.frame = view.bounds
        
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        loadingIndicator.stopAnimating()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: AuthorizationViewController.identifier)
        self.navigationController?.pushViewController(loginVC, animated: true)
    }

}

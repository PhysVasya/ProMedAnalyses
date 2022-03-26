//
//  LoadingPresentation.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 15.03.2022.
//

import Foundation
import UIKit

extension UIViewController {
    
    //The following method provides UIActivityIndicatorView with a string below it, offseted by 20. Escaping closure provides an ability to stop it later after any of the functions complete.
    func showLoadingData (label message: String?, onTaskCompletion: @escaping ((UIActivityIndicatorView)) -> Void) {
        DispatchQueue.main.async {
            let loadingIndicator = UIActivityIndicatorView(style: .medium)
            let loadingTextLabel = UILabel()
            loadingIndicator.frame = self.view.bounds
            loadingIndicator.hidesWhenStopped = true
            loadingTextLabel.textColor = .systemGray4
            loadingTextLabel.text = message
            loadingTextLabel.font = .systemFont(ofSize: 12, weight: .medium)
            loadingTextLabel.sizeToFit()
            loadingTextLabel.center = CGPoint(x: loadingIndicator.center.x, y: loadingIndicator.center.y + 20)
            loadingIndicator.addSubview(loadingTextLabel)
            
            self.view.addSubview(loadingIndicator)
            loadingIndicator.startAnimating()
            onTaskCompletion(loadingIndicator)
        }
    }
    
    ///   The following method basically shows an error to the user in form of alert controller with style .alert. It has one button "Cancel" by default
    /// - Parameters:
    ///   - message: The error message to provide to the user.
    ///   - addOKButton: Adds an "OK" button to the alert controller.
    ///   - completionHanlderOnFailure: Can be used after pressing "Cancel"
    ///   - completionHanlderOnSuccess: Can be used after pressing "OK"
    func showErrorToTheUser (with message: String?, addOKButton: Bool = false, completionHanlderOnFailure: (() -> Void)? = nil, completionHanlderOnSuccess: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Произошла ошибка", message: message, preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "OK", style: .default) { _ in
                alertController.dismiss(animated: true) {
                    completionHanlderOnSuccess?()
                }
            }
            let cancelAlertAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
                alertController.dismiss(animated: true) {
                    completionHanlderOnFailure?()
                }
            }
            alertController.addAction(cancelAlertAction)
            addOKButton ? alertController.addAction(dismissAlertAction) : nil
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
}

extension Date {
    //The date saved in CoreData with the type Date. This formatter converts it to string in preferred way.
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}

extension String {
    //In the recieving data from requests which is sometimes JSON, sometimes HTML code, the following method returns formatted Date for better visual presentation.
    func getFormattedDateFromString () -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: self)
    }
}

extension URLResponse {
    
    enum GettingCookieError: LocalizedError {
        case gotNil
        
        var errorDescription: String? {
            switch self {
            case .gotNil:
                return "Got nil from response"
            }
        }
    }
    
    // All of the methods in AuthorizationManages aim to collect Response header field "Set-Cookie". Extension is made to lessen the amount of repetative code.
    func getCookie (completion: (String) -> Void) throws {
        
        guard let urlResponse = self.url,
              let httpResponse = self as? HTTPURLResponse,
              let fields = httpResponse.allHeaderFields as? [String : String] else {
            throw GettingCookieError.gotNil
            
        }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: urlResponse)
        for cookie in cookies {
            var cookieProps = [HTTPCookiePropertyKey : Any]()
            cookieProps[.value] = cookie.value
            if let jSessionID = cookieProps[.value] as? String {
                completion(jSessionID)
            }
        }
    }
    
    
}

extension Sequence where Element: Hashable {
    
    func uniqued () -> [Element] {
        var set = Set<Element>()
        return filter {set.insert($0).inserted}
    }
    
}


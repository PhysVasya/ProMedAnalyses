//
//  LoadingPresentation.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 15.03.2022.
//

import Foundation
import UIKit

extension UIViewController {
    
    func dataIsLoading (with message: String?, onTaskCompletion: @escaping ((UIActivityIndicatorView)) -> Void) {
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
    
    /// extension of UIViewController, manages showing errors
    /// - Parameters:
    ///   - message: Type the message to show in alert controller
    ///   - addOKButton: Default value is false, therefore shows only "Cancel" button, completionHandler doesn't trigger.
    ///   - completionHanlder: Can be used only if OK button added
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
    
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}

extension String {
    
    func getFormattedDateFromString () -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: self)
    }
}



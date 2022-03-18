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
    
    func showErrorToTheUser (with message: String?, completionHanlder: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Произошла ошибка", message: message, preferredStyle: .alert)
            let dismissAlertAction = UIAlertAction(title: "OK", style: .cancel) { _ in
                alertController.dismiss(animated: true) {
                    completionHanlder?()
                }
            }
            alertController.addAction(dismissAlertAction)
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



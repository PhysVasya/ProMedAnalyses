//
//  Constants.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 21.12.2021.
//

import Foundation
import UIKit


struct K {
    static let patientTableCell = "patientCell"
    static let resultsTableCell = "resultsTableCell"
    static let nibResultsTableCell = "ResultsReusableCell"

    
    
    struct CoreData {
        static let managedPatient = "ManagedPatient"
        static let managedLabData = "ManagedLabData"
    }
    
    static func presentError (_ vc: UIViewController?, error: Error?, completion: (()->Void?)? = nil) {
        guard let er = error else {
            return
        }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "К сожалению, произошла ошибка", message: er.localizedDescription, preferredStyle: .alert)
            vc?.present(alertController, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    alertController.dismiss(animated: true) {
                        completion?()
                    }
                }
            }
        }
    }
}

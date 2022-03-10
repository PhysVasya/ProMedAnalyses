//
//  LoginScreenController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 13.02.2022.
//

import UIKit
import SwiftUI

class AuthorizationViewController: UIViewController {
    
    var loginText: String?
    static let identifier = "AuthorizationViewController"
    var loginCredentials : ((String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginCredentials = { [weak self] login, password in
            print(login, password)
            AuthorizationManager.shared.authorize(login: login, password: password) { success in
                switch success {
                
                case true:
                    HapticsManager.shared.vibrate(for: .success)
                    APICallManager.shared.getPatientsAndEvnIds { successful in
                        switch successful {
                            
                        case true:
                            DispatchQueue.main.async {
                                FetchingManager.shared.fetchPatientsFromCoreData { patients in
                                    self?.configurePatients(with: patients)
                                }
                            }
                            
                        case false:
                            print("CANNOT FETCH PATIENTS FROM PROMED")
                        }
                    }
                case false:
                    HapticsManager.shared.vibrate(for: .error)
                    DispatchQueue.main.async {
                        FetchingManager.shared.fetchPatientsFromCoreData { patients in
                            self?.unsuccessfulAuth(patientsVCwithCached: patients)
                        }
                    }
                    
                }
            }
        }
        
        let childVC = UIHostingController(rootView: LoginViewSwiftUI(sendData: loginCredentials))
        addChild(childVC)
        childVC.view.frame = view.bounds
        view.addSubview(childVC.view)
        title = "Логин"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapGesture)
        
            
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ConnectionViewController.shared.presentConnection(dependingOnReachability: (UIApplication.shared.delegate as! AppDelegate).connectionIsSatisfied) { success in
            print(success)
        }
        
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    @IBAction func forgetPasswordPressed (_ sender: UIButton) {
        let alertController = UIAlertController(title: "Не знаете логин?", message: "Обратитесь к Вашему системному администратору", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func configurePatients (with patients: [Patient]) {
        DispatchQueue.main.async { [weak self] in
            let patientVC = PatientsViewController()
            patientVC.configure(with: patients)
            self?.navigationController?.pushViewController(patientVC, animated: true)
        }
    }
    
    func unsuccessfulAuth (patientsVCwithCached: [Patient]) {
        
        let alertVC = UIAlertController(title: "Отсутствует соединение с инетрентом", message: "Загрузить локальные данные?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.configurePatients(with: patientsVCwithCached)
        }))
        alertVC.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { action in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        navigationController?.present(alertVC, animated: true, completion: nil)
    }
    
}

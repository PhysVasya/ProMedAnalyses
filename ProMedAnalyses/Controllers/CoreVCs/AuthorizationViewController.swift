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
    var loginResult : ((Bool) -> Void)?
    var forgetPasswordPressed: ((Bool) -> Void)?
    var isConnected: Bool {
        UserDefaults.standard.bool(forKey: "isConnected")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forgetPasswordPressed = { [weak self] _ in
            self?.manageForgetPasswordPressed()
        }
        
        loginResult = { [weak self] success in
            self?.manageLogin(using: success)
        }
        setupLoginScreen()
        manageTextFieldSelection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        manageOfflineConnection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ConnectionViewController.shared.presentConnection(dependingOnReachability: isConnected) { success in
            switch success {
            case true:
                print(success)
            case false:
                print(success)
            }
        }
    }
    
    private func setupLoginScreen() {
        let loginScreenSwiftUIView = UIHostingController(rootView: LoginViewSwiftUI(sendAuthorizationResult: loginResult, forgetPasswordPressed: forgetPasswordPressed))
        addChild(loginScreenSwiftUIView)
        loginScreenSwiftUIView.view.frame = view.bounds
        view.addSubview(loginScreenSwiftUIView.view)
    }
    
    private func manageTextFieldSelection () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapGesture)
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
    
    private func manageOfflineConnection () {
        if !isConnected {
            FetchingManager.shared.fetchPatientsFromCoreData { [weak self] patients in
                if patients.isEmpty {
                    self?.showErrorToTheUser(with: "На вашем устройстве отсутсвуют сохраненные пациенты. \n Пожалуйста, подключитесь к рабочей сети.")
                } else {
                    self?.showErrorToTheUser(with: "Отсутствует подключение к защищенной рабочей сети. \n\n Загрузить сохраненные данные?", addOKButton: true, completionHanlderOnSuccess: {
                        self?.presentPatients()
                    })
                }
            }
        }
    }
    
    func manageLogin (using: Bool) {
        if using {
            presentPatients()
        } else {
            unsuccessfulAuth()
        }
    }
    
    func manageForgetPasswordPressed () {
        let alertController = UIAlertController(title: "Не знаете логин?", message: "Обратитесь к Вашему системному администратору", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentPatients () {
        DispatchQueue.main.async {
            let patientVC = PatientsViewController()
            let navigationController = UINavigationController(rootViewController: patientVC)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.prefersLargeTitles = true
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func unsuccessfulAuth () {
        
        let alertVC = UIAlertController(title: "Отсутствует соединение с инетрентом", message: "Загрузить локальные данные?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.presentPatients()
        }))
        alertVC.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { action in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        present(alertVC, animated: true, completion: nil)
    }
}

struct AuthorizationViewControllerRepresentable : UIViewControllerRepresentable {
    
    typealias UIViewControllerType = AuthorizationViewController
    
    func makeUIViewController(context: Context) -> AuthorizationViewController {
        let vc = AuthorizationViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AuthorizationViewController, context: Context) {
        
    }
    
}


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
    var forgetPasswordPressed: ((Bool) -> Void)?
    var isConnected: Bool {
        UserDefaults.standard.bool(forKey: "isConnected")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forgetPasswordPressed = { [weak self] success in
            print(success)
            self?.manageForgetPasswordPressed()
        }
        
        loginCredentials = { [weak self] login, password in
            self?.manageLogin(using: login, password: password)
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
        let loginScreenSwiftUIView = UIHostingController(rootView: LoginViewSwiftUI(sendData: loginCredentials, forgetPasswordPressed: forgetPasswordPressed))
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
                    self?.showErrorToTheUser(with: "Unfortunately there is no saved patients on your device. Please connect to the working wifi at work.", completionHanlder: nil)
                } else {
                    self?.showErrorToTheUser(with: "Отсутствует подключение к защищенной рабочей сети. \n\n Производится попытка загрузки сохраненных данных", completionHanlder: {
                        self?.presentPatients()
                    })
                }
            }
        }
    }
    
    func manageLogin (using login: String, password: String) {
        dataIsLoading(with: "") { [weak self] indicator in
            AuthorizationManager.shared.authorize(login: login, password: password) { success in
                switch success {
                case true:
                    HapticsManager.shared.vibrate(for: .success)
                    self?.presentPatients()
                case false:
                    HapticsManager.shared.vibrate(for: .error)
                    self?.unsuccessfulAuth()
                }
            }
            DispatchQueue.main.async {
                indicator.stopAnimating()
            }
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


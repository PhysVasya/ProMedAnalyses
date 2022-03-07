//
//  LoginScreenController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 13.02.2022.
//

import UIKit

class AuthorizationViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    let dummyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: DummyLaunchScreen.identifier)

    
    var loginText: String?
    static let identifier = "AuthorizationViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        dummyVC.modalPresentationStyle = .overFullScreen
        navigationController?.present(dummyVC, animated: false)
        
        title = "Логин"
        loginButton.layer.cornerRadius = 10
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
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
            dummyVC.dismiss(animated: false, completion: nil)
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
    
    @IBAction func loginButtonPressed (_ sender: UIButton) {
        HapticsManager.shared.vibrateForSelection()
        
        if loginTextField.text != "" && passwordTextField.text != "" {
            AuthorizationManager.shared.authorize(login: loginTextField.text, password: passwordTextField.text) { [weak self] success in
                switch success {
                case true:
                    APICallManager.shared.getPatientsAndEvnIds { success in
                        switch success {
                        case true:
                            FetchingManager.shared.fetchPatientsFromCoreData { patients in
                                self?.configurePatients(with: patients)
                            }
                        case false:
                            print("FALSE")
                        }
                    }
                case false:
                    FetchingManager.shared.fetchPatientsFromCoreData { patients in
                        self?.unsuccessfulAuth(patientsVCwithCached: patients)
                    }
                }
            }
            
        } else {
            loginTextField.placeholder = "Введите логин"
            passwordTextField.placeholder = "Введите пароль"
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

extension AuthorizationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        loginText = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            loginButtonPressed(loginButton)
            textField.resignFirstResponder()
            return true
        } else {
            return false
        }
    }
    
}

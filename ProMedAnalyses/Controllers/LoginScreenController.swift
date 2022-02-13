//
//  LoginScreenController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 13.02.2022.
//

import Foundation
import UIKit


class LoginScreenController: UIViewController {
    
    @IBOutlet weak var http: UITextField!
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    
    var successful: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 10
        title = "Логин"
        
        let loginString = defaults.string(forKey: "Login")
        let httpString = defaults.string(forKey: "Link")
        
        http.text = httpString
        login.text = loginString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func loginButtonPressed (_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let patientVC = storyboard.instantiateViewController(withIdentifier: "patientsVC") as? PatientsViewController
        
        if http.text != "" && login.text != "" {
            patientVC?.link = http.text
            patientVC?.login = login.text
            navigationController?.pushViewController(patientVC!, animated: true)

        } else {
            http.text = ""
            http.placeholder = "Скопируйте ссылку на ПроМед из браузера"
            login.text = ""
            login.placeholder = "Введите логин для входа в личный кабинет"
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

}

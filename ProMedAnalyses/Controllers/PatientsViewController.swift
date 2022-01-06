//
//  ViewController.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 13.12.2021.
//

import UIKit
import WebKit
import SwiftSoup
import CoreData

class PatientsViewController: UIViewController {
    
    @IBOutlet var patientsTableView: UITableView!
    
    var container: NSPersistentContainer!
    var patients = [Patient]()
    var wards = [Int]()
    var namesArray = [String]()
    var datesAtrray = [String]()
    var wardNumberToMoveTo = ""
    
    //Loading Indicator to add visibility whether the process of loading is complete, initialized only
    let loadingIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        return indicator
    }()
    
    let alertwithError : UIAlertController = {
        let alert = UIAlertController(title: "К сожалению, возникла ошибка при загрузке данных.", message: "", preferredStyle: .alert)
        return alert
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        view.addSubview(loadingIndicator)
        loadingIndicator.frame = view.bounds
        loadingIndicator.startAnimating()
        
        patientsTableView.delegate = self
        patientsTableView.dataSource = self
        
        
        patients.append(Patient(name: "Елесин Василий Михайлович", dateOfBirth: "22.05.1995", ward: Ward(wardNumber: 1, wardType: .fourMan)))
        patients.append(Patient(name: "Янцер Чорт Лысый", dateOfBirth: "22.02.1998"))
        patients.append(Patient(name: "Яцков Егерь Анатолич", dateOfBirth: "10.02.1946"))
        patients.append(Patient(name: "Яков Ogar Анатолич", dateOfBirth: "10.02.1946", ward: Ward(wardNumber: 1, wardType: .fourMan)))
        patients.append(Patient(name: "Поц поцанович греков", dateOfBirth: "27.01.1925"))
        patients.append(Patient(name: "Меметов Мемет Меметович", dateOfBirth: "13.01.1930", ward: Ward(wardNumber: 2, wardType: .fourMan)))
        patients.append(Patient(name: "Меметов Мефет Меметович", dateOfBirth: "13.01.1930", ward: Ward(wardNumber: 3, wardType: .fourMan)))
        patients.append(Patient(name: "Кек Кекович Кеков", dateOfBirth: "11.04.1945", ward: Ward(wardNumber: 11, wardType: .fourMan)))
        
        getPatients()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    func deleteRow(with style: UIContextualAction.Style, on: IndexPath, table: UITableView) -> UIContextualAction {
        let delete = UIContextualAction(style: style, title: "Перевести из палаты") { [weak self] action, view, completionHandler in
            view.backgroundColor = .systemRed
            let groupedPatientsByWard = self?.patients.filter{ $0.ward.wardNumber == on.section }
            if let patientToBeDeleted = groupedPatientsByWard?[on.row] {
                
                if self?.patients.contains(patientToBeDeleted) != nil {
                    self?.patients.removeAll { identicalPatient in
                        patientToBeDeleted == identicalPatient
                    }
                    
                    self?.patients.append(Patient(name: patientToBeDeleted.name, dateOfBirth: patientToBeDeleted.dateOfBirth, ward: Ward(wardNumber: 0, wardType: .fourMan), id: patientToBeDeleted.id))
                } else {
                    return
                }
            }
            let indexPathToMoveTo = IndexPath(row: 0, section: 0)
            table.moveRow(at: on, to: indexPathToMoveTo)
            completionHandler(true)
        }
        return delete
    }
    
    func moveRow (with style: UIContextualAction.Style, on: IndexPath, table: UITableView) -> UIContextualAction {
        
        let chooseWardToMoveToAlertVC : UIAlertController = {
            let alertController = UIAlertController(title: "Выберите палату для перевода", message: "Введите номер палаты", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.delegate = self
                textField.placeholder = "Введите число от 1 до 21"
                textField.textAlignment = .center
                textField.keyboardType = .numberPad
            }
            
            return alertController
        }()
        chooseWardToMoveToAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            
            if self?.wardNumberToMoveTo != "" {
                let groupedPatientsByWard = self?.patients.filter{ $0.ward.wardNumber == on.section }
                if let patientToBeMoved = groupedPatientsByWard?[on.row] {
                    if self?.patients.contains(patientToBeMoved) != nil {
                        self?.patients.removeAll { existingPatient in
                            patientToBeMoved == existingPatient
                        }
                        self?.patients.append(Patient(name: patientToBeMoved.name, dateOfBirth: patientToBeMoved.dateOfBirth, ward: Ward(wardNumber: Int(self!.wardNumberToMoveTo) ?? (patientToBeMoved.ward.wardNumber), wardType: .fourMan), id: patientToBeMoved.id))
                    }
                }
                let indexPathToMoveTo = IndexPath(row: 0, section: Int(self!.wardNumberToMoveTo)!)
                table.moveRow(at: on, to: indexPathToMoveTo)
            } else {
                return
            }
        }
                                                         ))
        
        let move = UIContextualAction(style: style, title: "Перевести в палату") { [weak self] action, view, completionHandler in
            
            self?.present(chooseWardToMoveToAlertVC, animated: true) {
                completionHandler(true)
            }
        }
        move.backgroundColor = .systemBlue
        return move
    }
    
}

//MARK: - patientsTableView delegate methods

extension PatientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 22
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return patients.filter { $0.ward.wardNumber == section }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.patientTableCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = patients.filter { $0.ward.wardNumber == indexPath.section }[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var titleForHeader : [String] {
            var titleForHeader = [String]()
            var sections = [Int]()
            patients.forEach{ patient in
                sections.append(patient.ward.wardNumber)
            }
            for i in 0...21 {
                titleForHeader.append(String(i))
            }
            return titleForHeader
        }
        
        if section == 0 {
            return "Нераспределенные"
        } else {
            
            return String("Палата № \(titleForHeader[section])")
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        fetchPatientData(for: patients[indexPath.row].id)
        
        let destinationTableVC = ResultsViewController()
        destinationTableVC.modalPresentationStyle = .fullScreen
        destinationTableVC.title = "Результаты"
        destinationTableVC.headerForSection.append("Дата взятия биоматериала: 21/12/2021")
        navigationController?.pushViewController(destinationTableVC, animated: true)
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.numberOfRows(inSection: section) == 0 ? 0 : 20
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.numberOfRows(inSection: indexPath.section) == 0 ? 0 : 50
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 0 {
            let move = moveRow(with: .destructive, on: indexPath, table: tableView)
            let actions = UISwipeActionsConfiguration(actions: [move])
            return actions
        } else {
            let delete = deleteRow(with: .destructive, on: indexPath, table: tableView)
            let move = moveRow(with: .normal, on: indexPath, table: tableView)
            let actions = UISwipeActionsConfiguration(actions: [delete, move])
            return actions
        }
    }
    
    
}



//MARK: - Get Patients

extension PatientsViewController {
    
    func getPatients () {
        
        let urlForPatientRequest : URL? = {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "crimea.promedweb.ru"
            urlComponents.queryItems = [
                URLQueryItem(name: "c", value: "EvnSection"),
                URLQueryItem(name: "m", value: "getSectionTreeData")
            ]
            
            return urlComponents.url
        }()
        
        guard let url = urlForPatientRequest else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = [
            "Origin" : "https://crimea.promedweb.ru",
            "Referer" : "https://crimea.promedweb.ru/?c=promed",
            "X-Requested-With" : "XMLHttpRequest",
            "Content-Length" : "260",
            "Cookie" : "io=RfBjHdPK47cqqxKAAiCx; JSESSIONID=73241BF7A7E30974BD403C9D1D78F418; login=TischenkoZI; PHPSESSID=houoor2ctkcjsmn1mabc6r1en3"
            
        ]
        
        let requestBody = "object=LpuSection&object_id=LpuSection_id&object_value=19219&level=0&LpuSection_id=19219&ARMType=stac&date=06.01.2022&filter_Person_F=&filter_Person_I=&filter_Person_O=&filter_PSNumCard=&filter_Person_BirthDay=&filter_MedStaffFact_id=&MedService_id=0&node=root"
        urlRequest.httpBody = requestBody.data(using: .utf8)
        
        let sessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: sessionConfig)
        
        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self?.alertwithError.message = error?.localizedDescription
                    self?.present(self!.alertwithError, animated: true, completion: nil)
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        self?.alertwithError.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
            
            guard let unwrappedData = data else {
                return
            }
            
            let decoder = JSONDecoder()
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to retreive context.")
            }
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = self?.container.viewContext
            do {
                let decodedData = try decoder.decode([PatientsList].self, from: unwrappedData)
                try self?.container.viewContext.save()
                
                for patient in decodedData {
                    //                                        print(patient.patientId)
                    //                    print(patient.evnId)
                    let dataForPatientsTableView = try SwiftSoup.parse(patient.patientData!)
                    let patientNames = try dataForPatientsTableView.getElementsByTag("span").text()
                    let patient = Patient(name: patientNames.capitalized, dateOfBirth: "", id: patient.patientId!)
                    self?.patients.append(patient)
                    DispatchQueue.main.async {
                        self?.patientsTableView.reloadData()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.alertwithError.message = error.localizedDescription
                    self?.present(self!.alertwithError, animated: true, completion: nil)
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        self?.alertwithError.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        loadingIndicator.stopAnimating()
        task.resume()
    }
    
}

//MARK: - FetchPatientsData

extension PatientsViewController {
    
    func fetchPatientData(for patientId: String){
        
        let urlForRequest : URL? = {
            var urlComponents = URLComponents()
            urlComponents.host = "crimea.promedweb.ru"
            urlComponents.scheme = "https"
            urlComponents.queryItems = [
                URLQueryItem(name: "c", value: "Template"),
                URLQueryItem(name: "m", value: "getEvnFormEvnPS")
            ]
            
            return urlComponents.url
        }()
        
        guard let url = urlForRequest else {
            return
        }
        
        let urlRequest : URLRequest = {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "Origin" : "https://crimea.promedweb.ru",
                "Referer" : "https://crimea.promedweb.ru/?c=promed",
                "Content-Length" : "172",
                "X-Requested-With" : "XMLHttpRequest",
                "Cookie" : "io=sCcv3sqG_kbfCAeyAnzW; JSESSIONID=7D28392C267E9F0F94CBEA4505CACA97; login=TischenkoZI; PHPSESSID=houoor2ctkcjsmn1mabc6r1en3",
                "Accept-Language" : "en-GB,en;q=0.9",
                "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8"
            ]
            
            let requestBody = "user_MedStaffFact_id=89902&scroll_value=EvnPS_\(patientId)&object=EvnPS&object_id=EvnPS_id&object_value=\(patientId)&archiveRecord=0&ARMType=stac&from_MZ=1&from_MSE=1"
            request.httpBody = requestBody.data(using: .utf8)
            return request
        }()
        
        let sessionConfig = URLSessionConfiguration.default
        
        let urlSession = URLSession(configuration: sessionConfig)
        
        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self?.alertwithError.message = error?.localizedDescription
                    self?.present(self!.alertwithError, animated: true, completion: nil)
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        self?.alertwithError.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
            
            guard let receivedData = data else {
                return
            }
            
            let decoder = JSONDecoder()
            
            do{
                let decodedData = try decoder.decode(AnalysesList.self, from: receivedData)
                print(decodedData.html)
            } catch {
                DispatchQueue.main.async {
                    self?.alertwithError.message = error.localizedDescription
                    self?.present(self!.alertwithError, animated: true, completion: nil)
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        self?.alertwithError.dismiss(animated: true, completion: nil)
                    }
                }
            }
            
        }
        
        task.resume()
    }
    
    
}

//MARK: - TextField delegate methods

extension PatientsViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text != "" {
            if let textFieldText = textField.text {
                if Int(textFieldText)! > 21 {
                    //                    textField.isError(baseColor: CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), numberOfShakes: 4, revert: true)
                    
                    let outOfRangeAlert = UIAlertController(title: "Указанное значение выше установленного диапазона", message: "Введите число от 1 до 21", preferredStyle: .alert)
                    DispatchQueue.main.async {
                        self.present(outOfRangeAlert, animated: true, completion: nil)
                        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                            outOfRangeAlert.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    self.wardNumberToMoveTo = textFieldText
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.isError(baseColor: CGColor.init(red: 1, green: 0, blue: 0, alpha: 0.5), numberOfShakes: 3, revert: true)
        return true
    }
}


extension UITextField {
    func isError(baseColor: CGColor, numberOfShakes shakes: Float, revert: Bool) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "shadowColor")
        animation.fromValue = baseColor
        animation.toValue = UIColor.red.cgColor
        animation.duration = 0.4
        if revert { animation.autoreverses = true } else { animation.autoreverses = false }
        self.layer.add(animation, forKey: "shadowColor")
        
        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = shakes
        if revert { shake.autoreverses = true  } else { shake.autoreverses = false }
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
}

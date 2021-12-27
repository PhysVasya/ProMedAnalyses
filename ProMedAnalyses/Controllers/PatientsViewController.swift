//
//  ViewController.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 13.12.2021.
//

import UIKit
import WebKit
import SwiftSoup

class PatientsViewController: UIViewController {
    
    @IBOutlet var patientsTableView: UITableView!
    
    let loadingIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        return indicator
    }()
    
    var analysesData = [String]()
    var tableData = [ResultsTableData]()
    var collectionViewHeaderItems = [String]()
    var patients = [Patient]()
    
    let urlForRequest = URL(string: "https://crimea.promedweb.ru/?c=EvnXml&m=doLoadData")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patientsTableView.delegate = self
        patientsTableView.dataSource = self
        
        
        analysesData.append("С-реактивный \n белок")
        analysesData.append("1,0-10,0")
        analysesData.append("Более 40")
        analysesData.append("")
        
        collectionViewHeaderItems.append("Название услуги")
        collectionViewHeaderItems.append("Норма")
        collectionViewHeaderItems.append("Критические значения")
        collectionViewHeaderItems.append("Комментарии")
        
        patients.append(Patient(name: "Елесин Василий Михайлович", dateOfBirth: "22.05.1995", ward: 1))
        patients.append(Patient(name: "Янцер Чорт Лысый", dateOfBirth: "22.02.1998", ward: 2))
        patients.append(Patient(name: "Яцков Егерь Анатолич", dateOfBirth: "10.02.1946", ward: 2))
        patients.append(Patient(name: "Яков Ogar Анатолич", dateOfBirth: "10.02.1946", ward: 2))
        patients.append(Patient(name: "Поц поцанович греков", dateOfBirth: "27.01.1925", ward: 3))
        patients.append(Patient(name: "Меметов Мемет Меметович", dateOfBirth: "13.01.1930", ward: 5))
        patients.append(Patient(name: "Меметов Мемет Меметович", dateOfBirth: "13.01.1930", ward: 4))
        patients.append(Patient(name: "Кек Кекович Кеков", dateOfBirth: "11.04.1945", ward: 25))
        
        fetchData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func fetchData () {
        guard let url = urlForRequest else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
            "Origin" : "https://crimea.promedweb.ru",
            "Referer" : "https://crimea.promedweb.ru/?c=promed",
            "Content-Length" : "54",
            "Cookie" : "io=XavDNWBbRXzkCJFMATKQ; JSESSIONID=87A21185389261C543A100EC2607F3CF; login=TischenkoZI; PHPSESSID=houoor2ctkcjsmn1mabc6r1en3"
        ]
        
        let body = "XmlType_id=4&Evn_id=820910076978020&EvnXml_id=31197909"
        let finalBody = body.data(using: .utf8)
        request.httpBody = finalBody
        
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            
            if data != nil {
                if let unwrappedData = data {
                    print("Success")
                    print(String.init(data: unwrappedData, encoding: .utf8))
                }
            }
        }
        task.resume()
    }
    
}

//MARK: - patientsTableView delegate methods


extension PatientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var wards = [Int]()
        for patient in patients {
            wards.append(patient.ward.wardNumber)
        }
        
        if let maxWard = wards.max() {
            return maxWard
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var patientsInWards = [Patient]()
        
        for patient in patients {
            if patient.ward.wardNumber == section + 1 {
                patientsInWards.append(patient)
            }
        }
        
        return patientsInWards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.patientTableCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        let patientNames = patients.filter { patient in
            patient.ward.wardNumber == indexPath.section + 1
        }
        
        cell.textLabel?.text = patientNames[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var wardHeaderForSection = Int()
        
        for patient in patients {
            if patient.ward.wardNumber == section + 1 {
                wardHeaderForSection = patient.ward.wardNumber
            }
        }
        
        if wardHeaderForSection == section + 1 {
            return String("Палата №\(wardHeaderForSection)")
        } else {
            return nil
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let destinationTableVC = ResultsViewController()
        destinationTableVC.modalPresentationStyle = .fullScreen
        destinationTableVC.title = "Результаты"
        destinationTableVC.infoForRow = analysesData
        destinationTableVC.headerForSection.append("Дата взятия биоматериала: 21/12/2021")
        destinationTableVC.headerForCollectionView = collectionViewHeaderItems
        
        navigationController?.pushViewController(destinationTableVC, animated: true)
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
    }
}




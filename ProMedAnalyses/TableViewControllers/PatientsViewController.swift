//
//  ViewController.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 13.12.2021.
//

import UIKit
import WebKit
import SwiftSoup

class PatientsViewController: UIViewController, URLSessionDelegate {
    
    @IBOutlet var patientsTableView: UITableView!
    
    let loadingIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        return indicator
    }()
    
    var analysesData = [String]()
    var tableData = [ResultsTableData]()
    var collectionViewHeaderItems = [String]()
    var patients = [Patient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patientsTableView.delegate = self
        patientsTableView.dataSource = self
        
        analysesData.append("Ферритин")
        analysesData.append("CРБ")
        analysesData.append("Лейкоциты")
        analysesData.append("Моноциты")
        analysesData.append("АЛТ")
        
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
                
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        
        navigationController?.pushViewController(destinationTableVC, animated: true)    }
}

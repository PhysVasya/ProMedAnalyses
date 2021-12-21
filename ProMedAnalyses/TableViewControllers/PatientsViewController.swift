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
    var patients = [PatientsTableData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patientsTableView.delegate = self
        patientsTableView.dataSource = self

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func showTableVC(_ sender: Any) {
        
        let destinationTableVC = ResultsViewController()
        destinationTableVC.modalPresentationStyle = .fullScreen
        destinationTableVC.title = "Результаты"
        destinationTableVC.infoForRow = analysesData
        destinationTableVC.headerForSection.append(tableData[3].htmlElement.ownText())
        destinationTableVC.headerForCollectionView = collectionViewHeaderItems
        
        navigationController?.pushViewController(destinationTableVC, animated: true)
    }
    
 
   
}

//MARK: - patientsTableView delegate methods


extension PatientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.patientTableCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Пациент"
        return cell
    }
}

//
//  ViewController.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 13.12.2021.
//

import UIKit
import CoreData
import SwiftUI

class PatientsByWardsViewController: UIViewController {
    
    static let identifier = "PatientsByWardsViewController"
    static let cellIdentifier = "PatientsByWardsCellController"
    
    private var patients: [Patient]? 
    private var filteredPatients = [Patient]()
    private var analysesTypes = [AnalysisType]()
    
    private var wardNumberToMoveTo = ""
    
    private var isSearchBarEmpty : Bool {
        return search.searchBar.searchTextField.text?.isEmpty ?? true
    }
    private var searchFieldIsEditing : Bool {
        return search.isActive && !isSearchBarEmpty
    }
    private var isConnected : Bool? {
        UserDefaults.standard.bool(forKey: "isConnected")
    }
 
    
    private let patientsTableView = UITableView(frame: .zero, style: .plain)
    
    private let search = UISearchController(searchResultsController: nil)
    private let refresh = UIRefreshControl()
    private var onlyPatientsWithAnalysesPressed : ((Bool) -> Void)?
    private var onlyHighCRPPressed: ((Bool)->Void)?
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список по палатам"
        navigationController?.navigationBar.isHidden = false
                
        configureTableView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRefreshControl()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        patientsTableView.frame = view.bounds
        patientsTableView.reloadData()
        ConnectionViewController.shared.removeConnectionPresentation()
        patientsTableView.tableHeaderView?.layoutIfNeeded()
    }
    
    convenience init () {
        self.init(patients: nil)
    }
    
    public init (patients: [Patient]?) {
        super.init(nibName: nil, bundle: nil)
        self.patients = patients
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configureTableView () {
        view.addSubview(patientsTableView)
        patientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: PatientsByWardsViewController.cellIdentifier)
        patientsTableView.delegate = self
        patientsTableView.dataSource = self
        let headerView = UIHostingController(rootView: TableHeaderView(onSavedButtonPressed: onlyPatientsWithAnalysesPressed, onHighCRPButtonPressed: onlyHighCRPPressed))
        headerView.view.translatesAutoresizingMaskIntoConstraints = false
        patientsTableView.tableHeaderView = headerView.view
        patientsTableView.contentInset.bottom = tabBarController?.tabBar.frame.height ?? 0

    }
    
    
    
    private func setupSearchController () {
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Искать..."
        search.searchBar.autocapitalizationType = .words
        navigationItem.searchController = search
        definesPresentationContext = true
    }
    
    private func setupRefreshControl () {
        refresh.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "Обновление данных...")
        patientsTableView.refreshControl = refresh
    }
    
    
    
    private func manageFetchingPatients (visually: UIActivityIndicatorView) {
        if isConnected == true {
            APICallManager.shared.getPatientsAndEvnIds { [weak self] _ in
                FetchingManager.shared.fetchPatientsFromCoreData { patients in
                    self?.patients = patients
                }
                DispatchQueue.main.async {
                    self?.patientsTableView.reloadData()
                    visually.stopAnimating()
                }
            }
        } else {
            FetchingManager.shared.fetchPatientsFromCoreData { [weak self] patients in
                self?.patients = patients
                
                DispatchQueue.main.async {
                    self?.patientsTableView.reloadData()
                    visually.stopAnimating()
                }
            }
        }
    }
    
  
    
    
    @objc private func refreshData (sender: UIRefreshControl) {
        guard let isConnected = isConnected else {
            return
        }
        if isConnected {
            APICallManager.shared.getPatientsAndEvnIds { [weak self] success in
                switch success {
                case true:
                    FetchingManager.shared.fetchPatientsFromCoreData { receivedPatients in
                        self?.patients = receivedPatients
                        DispatchQueue.main.async {
                            self?.patientsTableView.reloadData()
                            self?.refresh.endRefreshing()
                        }
                    }
                case false:
                    print("FALSE")
                }
            }
        } else {
            FetchingManager.shared.fetchPatientsFromCoreData { [weak self] receivedPatients in
                self?.patients = receivedPatients
                DispatchQueue.main.async {
                    self?.patientsTableView.reloadData()
                    self?.refresh.endRefreshing()
                }
            }
        }
        
    }
    

    
    private func presentResults (for patient: Patient) {
        DispatchQueue.main.async {
            let destinationVC = ResultsViewController()
            destinationVC.patient = patient
            destinationVC.title = patient.name
            destinationVC.navigationItem.largeTitleDisplayMode = .never
            destinationVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
}

//MARK: - PatientsTableView delegate methods and custom Table methods
extension PatientsByWardsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 27
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchFieldIsEditing {
            return filteredPatients.filter { $0.ward.wardNumber == section}.count
        } else {
            return patients!.filter{ $0.ward.wardNumber == section }.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PatientsByWardsViewController.cellIdentifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        var content = cell.defaultContentConfiguration()
        
        let patient : Patient
        
        if searchFieldIsEditing {
            let filteredPatientsWardEqualSection = filteredPatients.filter { $0.ward.wardNumber == indexPath.section }
            patient = filteredPatientsWardEqualSection[indexPath.row]
        } else {
            let patientsWardEqualSection = patients!.filter { $0.ward.wardNumber == indexPath.section }
            patient = patientsWardEqualSection[indexPath.row]
        }
        content.textProperties.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12, weight: .light)
        content.text = patient.name
        content.secondaryText = "Поступил: \(patient.dateOfAdmission)"
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let filteredPatientsByWard = patients!.filter{ $0.ward.wardNumber == section }
        if filteredPatientsByWard.isEmpty {
            return nil
        } else if section == 0 {
            return "Нераспределенные"
        } else {
            return String("Палата № \(section)")
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return patients?.filter { $0.ward.wardNumber == section }.isEmpty ?? true ? CGFloat.leastNonzeroMagnitude : 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return patients?.filter{ $0.ward.wardNumber == section}.isEmpty ?? true ? CGFloat.leastNonzeroMagnitude : 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        
        if searchFieldIsEditing {
            presentResults(for: filteredPatients[indexPath.row])
        } else {
            let filteredPatientsByWard = patients?.filter{ $0.ward.wardNumber == indexPath.section }
            presentResults(for: (filteredPatientsByWard?[indexPath.row])!)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return patients?.filter { $0.ward.wardNumber == indexPath.section}.isEmpty ?? true ? CGFloat.leastNonzeroMagnitude : 60
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return searchFieldIsEditing ? false : true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 0 {
            let move = movePatient(with: .destructive, on: indexPath, table: tableView)
            let actions = UISwipeActionsConfiguration(actions: [move])
            return actions
        } else {
            let delete = removePatientFromWard(with: .destructive, on: indexPath, table: tableView)
            let move = movePatient(with: .normal, on: indexPath, table: tableView)
            let actions = UISwipeActionsConfiguration(actions: [delete, move])
            return actions
        }
    }
    
    
    //Custom trailing swipe actions
    func removePatientFromWard(with style: UIContextualAction.Style, on: IndexPath, table: UITableView) -> UIContextualAction {
        let delete = UIContextualAction(style: style, title: "Перевести из палаты") { [weak self] action, view, completionHandler in
            view.backgroundColor = .systemRed
            let groupedPatientsByWard = self?.patients?.filter{ $0.ward.wardNumber == on.section }
            if var patientToBeDeleted = groupedPatientsByWard?[on.row] {
                if self?.patients?.contains(patientToBeDeleted) != nil {
                    self?.patients?.removeAll { $0.patientID == patientToBeDeleted.patientID}
                    FetchingManager.shared.changeWardAndSavePatient(patient: patientToBeDeleted, moveTo: 0)
                    let indexPathToMoveTo = IndexPath(row: 0, section: 0)
                    patientToBeDeleted.ward.wardNumber = 0
                    self?.patients?.append(patientToBeDeleted)
                    table.moveRow(at: on, to: indexPathToMoveTo)
                    
                } else {
                    return
                }
            }
            
            completionHandler(true)
        }
        return delete
    }
    
    func movePatient (with style: UIContextualAction.Style, on: IndexPath, table: UITableView) -> UIContextualAction {
        self.wardNumberToMoveTo = ""
        let chooseWardToMoveToAlertVC : UIAlertController = {
            let alertController = UIAlertController(title: "Выберите палату для перевода", message: "Введите номер палаты", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.delegate = self
                textField.placeholder = "Введите число от 1 до 27"
                textField.textAlignment = .center
                textField.keyboardType = .numberPad
            }
            return alertController
        }()
        
        let action = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            let groupedPatientsByWard = self?.patients?.filter{ $0.ward.wardNumber == on.section }
            if var patientToBeMoved = groupedPatientsByWard?[on.row] {
                if self?.patients?.contains(patientToBeMoved) != nil {
                    self?.patients?.removeAll(where: {$0.patientID == patientToBeMoved.patientID})
                    FetchingManager.shared.changeWardAndSavePatient(patient: patientToBeMoved, moveTo: Int(self!.wardNumberToMoveTo)!)
                    let indexPathToMoveTo = IndexPath(row: 0, section: Int(self!.wardNumberToMoveTo)!)
                    patientToBeMoved.ward.wardNumber = Int(self!.wardNumberToMoveTo)!
                    self?.patients?.append(patientToBeMoved)
                    table.moveRow(at: on, to: indexPathToMoveTo)
                }
            }
            
        })
        
        let cancel = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            chooseWardToMoveToAlertVC.dismiss(animated: true, completion: nil)
        }
        
        chooseWardToMoveToAlertVC.addAction(action)
        chooseWardToMoveToAlertVC.addAction(cancel)
        let move = UIContextualAction(style: style, title: "Перевести в палату") { [weak self] action, view, completionHandler in
            self?.present(chooseWardToMoveToAlertVC, animated: true) {
                completionHandler(true)
            }
        }
        move.backgroundColor = .systemBlue
        return move
    }
}




//MARK: - TextField delegate methods
extension PatientsByWardsViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            if let textFieldText = textField.text {
                if Int(textFieldText)! > 21 {
                    let outOfRangeAlert = UIAlertController(title: "Указанное значение выше установленного диапазона", message: "Введите число от 1 до 27", preferredStyle: .alert)
                    self.present(outOfRangeAlert, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        outOfRangeAlert.dismiss(animated: true, completion: nil)
                    })
                } else {
                    self.wardNumberToMoveTo = textFieldText
                }
            }
        }
    }
}


//MARK: - searchController delegate
extension PatientsByWardsViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchTextField(searchBar.text!)
    }
    
    private func filterContentForSearchTextField (_ textToSearch: String) {
        filteredPatients = (patients?.filter {$0.name.lowercased().contains(textToSearch.lowercased()) || $0.dateOfAdmission.lowercased().contains(textToSearch.lowercased())})!
        patientsTableView.reloadData()
    }
}



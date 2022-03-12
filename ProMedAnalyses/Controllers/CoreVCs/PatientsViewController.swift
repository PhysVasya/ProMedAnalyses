//
//  ViewController.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 13.12.2021.
//

import UIKit
import CoreData
import SwiftUI

class PatientsViewController: UIViewController {
    
    static let identifier = "PatientsViewController"
    static let cellIdentifier = "PatientsCellController"
    
    private let patientsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        return tableView
    }()
    
    private let search = UISearchController(searchResultsController: nil)
    private let refresh = UIRefreshControl()

    private var onlyPatientsWithAnalysesPressed : ((Bool) -> Void)?
    private var onlyHighCRPPressed: ((Bool)->Void)?
    private var isConnected : Bool? {
        UserDefaults.standard.bool(forKey: "isConnected")
    }
    private var downloadingViewShouldStayPresented: ((Bool) -> Void)?
    private var rootView : UIViewController {
        let vc = UIHostingController(rootView: LoadingAllDataAlert(shouldStayOnScreen: downloadingViewShouldStayPresented))
        vc.sheetPresentationController?.detents = [.medium()]
        vc.sheetPresentationController?.selectedDetentIdentifier = .medium
        return vc
    }

    private var patients = [Patient]()
    private var filteredPatients = [Patient]()
    private var wardNumberToMoveTo = ""
    private var isSearchBarEmpty : Bool {
        return search.searchBar.searchTextField.text?.isEmpty ?? true
    }
    private var searchFieldIsEditing : Bool {
        return search.isActive && !isSearchBarEmpty
    }
    private var currentPatient : ManagedPatient?
    private var analysesTypes = [AnalysisType]()
     
    //View overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список пациентов"
        navigationController?.navigationBar.isHidden = false
        onlyPatientsWithAnalysesPressed = { [weak self] success in
            switch success {
            case true:
                self?.applyFilter()
            case false:
                FetchingManager.shared.fetchPatientsFromCoreData { patients in
                    self?.patients = patients
                    self?.patientsTableView.reloadData()
                }
            }
        }
        onlyHighCRPPressed = { [weak self] success in
            switch success {
            case true:
                print("NOT KEK")
            case false:
                print("KEK")
            }
            
        }
        downloadingViewShouldStayPresented = { success in
            switch success {
            case true:
                print(success)
            case false:
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
            
        }
        
        configureTableView()
        configureNavigationBar()
        
    }
    
    private func configureNavigationBar () {
        let menuElement = UIAction(title: "Загрузить все данные", image: UIImage(systemName: "arrow.down.circle")) { action in
            let alert = UIAlertController(title: "Загрузить все данные?", message: "Вы уверены, что хотите загрузить данные всех пациентов? \n Это займёт некоторое время", preferredStyle: .alert)
            let processAction = UIAlertAction(title: "Загрузить", style: .default, handler: { action in
                self.navigationController?.present(self.rootView, animated: true, completion: nil)
                })
            let dismissAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(processAction)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)

        }
        let navBarRightButton = UIBarButtonItem(systemItem: .action, primaryAction: nil, menu: UIMenu(title: "", children: [menuElement]))
        navBarRightButton.tintColor = UIColor(named: "ColorOrange")
        navigationItem.setRightBarButton(navBarRightButton, animated: false)
 
    }
    
  
        
        
       
        
    private func configureTableView () {
        view.addSubview(patientsTableView)
        patientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: PatientsViewController.cellIdentifier)
        patientsTableView.delegate = self
        patientsTableView.dataSource = self
        let headerView = UIHostingController(rootView: TableHeaderView(onSavedButtonPressed: onlyPatientsWithAnalysesPressed, onHighCRPButtonPressed: onlyHighCRPPressed))
        patientsTableView.tableHeaderView = headerView.view
        headerView.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func applyFilter () {
        FetchingManager.shared.fetchOnlyPatientsWithAnalyses { patients in
            self.patients = patients
            patientsTableView.reloadData()
        }
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
    
    public func configure(with patients: [Patient]) {
        self.patients = patients
    }
    
    @objc private func refreshData (sender: UIRefreshControl) {
        guard let isConnected = isConnected else {
            return
        }
        if isConnected {
            APICallManager.shared.getPatientsAndEvnIds { success in
                switch success {
                case true:
                    FetchingManager.shared.fetchPatientsFromCoreData { receivedPatients in
                        self.patients = receivedPatients
                    }
                case false:
                    print("FALSE")
                }
            }
        } else {
            FetchingManager.shared.fetchPatientsFromCoreData { receivedPatients in
                self.patients = receivedPatients
            }
        }
        patientsTableView.reloadData()
        refresh.endRefreshing()
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
        refresh.addTarget(self, action: #selector(PatientsViewController.refreshData(sender:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "Обновление данных...")
        patientsTableView.refreshControl = refresh
    }
    
    private func filterContentForSearchTextField (_ textToSearch: String) {
        filteredPatients = patients.filter {$0.name.lowercased().contains(textToSearch.lowercased()) || $0.dateOfAdmission.lowercased().contains(textToSearch.lowercased())}
        patientsTableView.reloadData()
    }
 
    private func configureResults (for patient: Patient) {
        
        guard let connectionAvailiable = isConnected else {
            return
        }
        
        switch connectionAvailiable {
        case true:
            APICallManager.shared.downloadAndSaveLabData(for: patient) { [weak self] labData in
                let labDataFormatted = labData.compactMap{$0.formattedToViewModel}
                self?.presentResults(with: labDataFormatted)
            }
        case false:
            FetchingManager.shared.fetchLabDataFromCoreData(for: patient) { [weak self] analyses in
                self?.presentResults(with: analyses)
            }
        }
    }

    private func presentResults (with analyses: [AnalysisViewModel]) {
        DispatchQueue.main.async {
            if analyses.isEmpty {
                let alertCont = UIAlertController(title: "Ошибка", message: "К сожалению, данных для отображения нет.", preferredStyle: .alert)
                let dismissAlertAction = UIAlertAction(title: "ОК", style: .cancel) { act in
                    alertCont.dismiss(animated: true, completion: nil)
                }
                alertCont.addAction(dismissAlertAction)
                self.present(alertCont, animated: true, completion: nil)
            } else {
                let destinationVC = ResultsViewController()
                destinationVC.modalPresentationStyle = .fullScreen
                destinationVC.configureResultsVC(with: analyses)
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    
}

//MARK: - PatientsTableView delegate methods and custom Table methods
extension PatientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 27
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filteredPatientsByWard = patients.filter{ $0.ward.wardNumber == section }
        if filteredPatientsByWard.isEmpty {
            return 0
        } else if searchFieldIsEditing {
            return filteredPatients.filter { $0.ward.wardNumber == section}.count
        } else {
            return patients.filter { $0.ward.wardNumber == section }.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PatientsViewController.cellIdentifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        var content = cell.defaultContentConfiguration()
        
        let patient : Patient
        
        if searchFieldIsEditing {
            let filteredPatientsWardEqualSection = filteredPatients.filter { $0.ward.wardNumber == indexPath.section }
            patient = filteredPatientsWardEqualSection[indexPath.row]
        } else {
            let patientsWardEqualSection = patients.filter { $0.ward.wardNumber == indexPath.section }
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
        
        let filteredPatientsByWard = patients.filter{ $0.ward.wardNumber == section }
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
        return patients.filter { $0.ward.wardNumber == section }.isEmpty ? CGFloat.leastNonzeroMagnitude : 20 
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return patients.filter{ $0.ward.wardNumber == section}.isEmpty ? CGFloat.leastNonzeroMagnitude : 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)

        if searchFieldIsEditing {
            configureResults(for: filteredPatients[indexPath.row])
        } else {
            let filteredPatientsByWard = patients.filter{ $0.ward.wardNumber == indexPath.section }
            configureResults(for: filteredPatientsByWard[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return patients.filter { $0.ward.wardNumber == indexPath.section}.isEmpty ? CGFloat.leastNonzeroMagnitude : 60
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
            let groupedPatientsByWard = self?.patients.filter{ $0.ward.wardNumber == on.section }
            if let patientToBeDeleted = groupedPatientsByWard?[on.row] {
                
                if self?.patients.contains(patientToBeDeleted) != nil {
                    self?.patients.removeAll { identicalPatient in
                        patientToBeDeleted == identicalPatient
                    }
                    self?.currentPatient?.patientName = patientToBeDeleted.name
                    self?.currentPatient?.patientID = patientToBeDeleted.patientID
                    self?.currentPatient?.dateOfAdmission = patientToBeDeleted.dateOfAdmission.getFormattedDateFromString()
                    self?.currentPatient?.wardNumber = Int16(patientToBeDeleted.ward.wardNumber)

                    FetchingManager.shared.deletePatient(patient: self?.currentPatient)
        
                    self?.patients.append(Patient(name: patientToBeDeleted.name, dateOfAdmission: patientToBeDeleted.dateOfAdmission, ward: Ward(wardNumber: 0, wardType: .fourMan), patientID: patientToBeDeleted.patientID))
                    self?.currentPatient?.wardNumber = 0

                    FetchingManager.shared.savePatient(patient: patientToBeDeleted)
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
            let groupedPatientsByWard = self?.patients.filter{ $0.ward.wardNumber == on.section }
            if let patientToBeMoved = groupedPatientsByWard?[on.row] {
                if self?.patients.contains(patientToBeMoved) != nil {
                    self?.patients.removeAll { existingPatient in
                        patientToBeMoved == existingPatient
                    }
                    self?.currentPatient?.patientName = patientToBeMoved.name
                    self?.currentPatient?.patientID = patientToBeMoved.patientID
                    self?.currentPatient?.dateOfAdmission = patientToBeMoved.dateOfAdmission.getFormattedDateFromString()
                    self?.currentPatient?.wardNumber = Int16(patientToBeMoved.ward.wardNumber)

                    FetchingManager.shared.deletePatient(patient: self?.currentPatient)

                    self?.patients.append(Patient(name: patientToBeMoved.name, dateOfAdmission: patientToBeMoved.dateOfAdmission, ward: Ward(wardNumber: Int(self!.wardNumberToMoveTo)! , wardType: .fourMan), patientID: patientToBeMoved.patientID))
                    self?.currentPatient?.wardNumber = Int16(self!.wardNumberToMoveTo)!
                    
                    FetchingManager.shared.savePatient(patient: patientToBeMoved)
                }
            }
            let indexPathToMoveTo = IndexPath(row: 0, section: Int(self!.wardNumberToMoveTo)!)
            table.moveRow(at: on, to: indexPathToMoveTo)
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
extension PatientsViewController : UITextFieldDelegate {
    
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
extension PatientsViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchTextField(searchBar.text!)
    }
}

extension Date {
    
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}

extension String {
    
    func getFormattedDateFromString () -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: self)
    }
}

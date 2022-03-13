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
    
    var ascending: Bool = false


    private var onlyPatientsWithAnalysesPressed : ((Bool) -> Void)?
    private var onlyHighCRPPressed: ((Bool)->Void)?
    private var isConnected : Bool? {
        UserDefaults.standard.bool(forKey: "isConnected")
    }
    private var downloadingViewShouldStayPresented: ((Bool) -> Void)?
    private var progressDownloadView : UIViewController {
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
    private var analysesTypes = [AnalysisType]()
     
    //View overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список пациентов"
        navigationController?.navigationBar.isHidden = false
        onlyPatientsWithAnalysesPressed = { [weak self] success in
            switch success {
            case true:
                self?.patientsTableView.refreshControl = nil
                self?.applyFilter()
            case false:
                self?.patientsTableView.refreshControl = self?.refresh
                FetchingManager.shared.fetchPatientsFromCoreData { patients in
                    self?.patients = patients
                    self?.patientsTableView.reloadData()
                }
            }
        }
        onlyHighCRPPressed = { [weak self] success in
            switch success {
            case true:
                self?.patientsTableView.refreshControl = nil
                FetchingManager.shared.fetchPatientsWithHighCRP { patients in
                    self?.patients = patients
                    self?.patientsTableView.reloadData()
                }
            case false:
                self?.patientsTableView.refreshControl = self?.refresh
                FetchingManager.shared.fetchPatientsFromCoreData { patients in
                    self?.patients = patients
                    self?.patientsTableView.reloadData()
                }
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
        
        
        
        let menuElement1 = UIAction(title: "Загрузить все данные", image: UIImage(systemName: "arrow.down.circle")?.withTintColor(.label, renderingMode: .alwaysOriginal)) { [weak self] action in
            let alertOnConnection = UIAlertController(title: "Загрузить все данные?", message: "Вы уверены, что хотите загрузить данные всех пациентов? \n Это займёт некоторое время", preferredStyle: .alert)
            let processAction = UIAlertAction(title: "Загрузить", style: .default, handler: { action in
              self?.navigationController?.present(self!.progressDownloadView, animated: true, completion: nil)
                })
            let dismissAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                alertOnConnection.dismiss(animated: true, completion: nil)
            }
            alertOnConnection.addAction(processAction)
            alertOnConnection.addAction(dismissAction)
            
            let alertOffConnection = UIAlertController(title: "Ошибка", message: "Данное действие невозможно, ввиду отсутствия должного интернет подключения.", preferredStyle: .alert)
            let offConnectionDismiss = UIAlertAction(title: "Отмена", style: .cancel) { action in
                alertOffConnection.dismiss(animated: true, completion: nil)
            }
            alertOffConnection.addAction(offConnectionDismiss)
            
            if self?.isConnected == true {
                self?.present(alertOnConnection, animated: true, completion: nil)

            } else {
                self?.present(alertOffConnection, animated: true, completion: nil)
            }

        }
       
        let navBarButton1 = UIBarButtonItem(systemItem: .action, primaryAction: nil, menu: UIMenu(title: "", children: [menuElement1]))
        navBarButton1.tintColor = UIColor(named: "ColorOrange")
        
        let menuElement2 = UIAction(title: "По имени", image: UIImage(systemName: "person")) { [weak self] action in
            self?.sortPatients(with: .name)
        }
        let menuElement3 = UIAction(title: "По дате поступления", image: UIImage(systemName: "calendar")) { [weak self] action in
            self?.sortPatients(with: .date)
        }
        
        let navBarButton2 = UIBarButtonItem(image: UIImage(systemName: "list.dash"), menu: UIMenu(title: "Сортировать", children: [menuElement2, menuElement3]))
        navBarButton2.tintColor = UIColor(named: "ColorOrange")
        navigationItem.setRightBarButtonItems([navBarButton1, navBarButton2], animated: false)
 
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
    
    private func sortPatients (with filter: PatientFilter) {
        switch filter {

        case .date:

            patients = patients.sorted { n1, n2 in
                ascending ? n1.dateOfAdmission.getFormattedDateFromString()! > n2.dateOfAdmission.getFormattedDateFromString()! :
                n1.dateOfAdmission.getFormattedDateFromString()! < n2.dateOfAdmission.getFormattedDateFromString()!
            }
            patientsTableView.reloadData()
            ascending = !ascending
        case .name:
           
            patients = patients.sorted { n1, n2 in
                
                ascending ? n1.name.first! > n2.name.first! : n1.name.first! < n2.name.first!
                
            }
            patientsTableView.reloadData()
            ascending = !ascending
        }
        
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
         if searchFieldIsEditing {
            return filteredPatients.filter { $0.ward.wardNumber == section}.count
        } else {
            return patients.filter{ $0.ward.wardNumber == section }.count
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
            if var patientToBeDeleted = groupedPatientsByWard?[on.row] {
                if self?.patients.contains(patientToBeDeleted) != nil {
                    self?.patients.removeAll { $0.patientID == patientToBeDeleted.patientID}
                    FetchingManager.shared.changeWardAndSavePatient(patient: patientToBeDeleted, moveTo: 0)
                    let indexPathToMoveTo = IndexPath(row: 0, section: 0)
                    patientToBeDeleted.ward.wardNumber = 0
                    self?.patients.append(patientToBeDeleted)
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
            let groupedPatientsByWard = self?.patients.filter{ $0.ward.wardNumber == on.section }
            if var patientToBeMoved = groupedPatientsByWard?[on.row] {
                if self?.patients.contains(patientToBeMoved) != nil {
                    self?.patients.removeAll(where: {$0.patientID == patientToBeMoved.patientID})
                    FetchingManager.shared.changeWardAndSavePatient(patient: patientToBeMoved, moveTo: Int(self!.wardNumberToMoveTo)!)
                    let indexPathToMoveTo = IndexPath(row: 0, section: Int(self!.wardNumberToMoveTo)!)
                    patientToBeMoved.ward.wardNumber = Int(self!.wardNumberToMoveTo)!
                    self?.patients.append(patientToBeMoved)
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

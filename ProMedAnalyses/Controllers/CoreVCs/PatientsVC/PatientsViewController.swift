//
//  PatientsByWardsViewController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 23.03.2022.
//

import Foundation
import UIKit
import SwiftUI

class PatientsViewController: UIViewController {
    
    static let cellIdentidifer = "PatientsViewControllerCell"
    let tableView = UITableView(frame: .zero, style: .plain)
    let search = UISearchController(searchResultsController: nil)
    let refresh = UIRefreshControl()
    var patients = [Patient]()
    var searchFilteredPatients = [Patient]()
    var isSearchFieldEditing : Bool {
        return !isSearchFieldEmpty && search.isActive
    }
    var isSearchFieldEmpty: Bool {
        return search.searchBar.searchTextField.text?.isEmpty ?? true
    }
    private var ascending: Bool = false
    
    private var onlyPatientsWithAnalysesPressed : ((Bool) -> Void)?
    private var onlyHighCRPPressed: ((Bool)->Void)?
    private var downloadingViewShouldStayPresented: ((Bool) -> Void)?
    
    private var isConnected : Bool? {
        UserDefaults.standard.bool(forKey: "isConnected")
    }
    
    private var progressDownloadView : UIViewController {
        let vc = UIHostingController(rootView: LoadingAllDataAlert(shouldStayOnScreen: downloadingViewShouldStayPresented))
        vc.sheetPresentationController?.detents = [.medium()]
        vc.sheetPresentationController?.selectedDetentIdentifier = .medium
        vc.isModalInPresentation = true
        return vc
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onlyPatientsWithAnalysesPressed = { [weak self] pressed in
            self?.manageOnlyPatientsWithAnalysesButtonPressed(buttonPressed: pressed)
        }
        
        onlyHighCRPPressed = { [weak self] pressed in
            self?.manageHightCRPOnlyButtonPressed(buttonPressed: pressed)
        }
        
        downloadingViewShouldStayPresented = { [weak self] boolean in
            self?.manageDownloadAllVisualPresentation(shouldIt: boolean)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PatientsViewController.cellIdentidifer)
        tableView.contentInset.bottom = tabBarController?.tabBar.frame.height ?? 0
        view.addSubview(tableView)
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Искать..."
        search.searchBar.autocapitalizationType = .words
        search.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = false
        navigationItem.searchController = search
        title = "Общий список"
        refresh.attributedTitle = NSAttributedString(string: "Обновление данных...")
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        let headerView = UIHostingController(rootView: TableHeaderView(onSavedButtonPressed: onlyPatientsWithAnalysesPressed, onHighCRPButtonPressed: onlyHighCRPPressed))
        headerView.view.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView.view
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        tableView.reloadData()
        tableView.tableHeaderView?.layoutIfNeeded()
        
    }
    
    convenience init () {
        self.init(patients: nil)
    }
    
    public init(patients: [Patient]?) {
        super.init(nibName: nil, bundle: nil)
        self.patients = patients!
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
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
                            self?.tableView.reloadData()
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
                    self?.tableView.reloadData()
                    self?.refresh.endRefreshing()
                }
            }
        }
        
    }
    
    private func manageHightCRPOnlyButtonPressed (buttonPressed: Bool) {
        switch buttonPressed {
        case true:
            tableView.refreshControl = nil
            FetchingManager.shared.fetchPatientsWithHighCRP { patients in
                self.patients = patients
                tableView.reloadData()
            }
        case false:
            tableView.refreshControl = refresh
            FetchingManager.shared.fetchPatientsFromCoreData { patients in
                self.patients = patients
                tableView.reloadData()
            }
        }
    }
    
    private func manageDownloadAllVisualPresentation (shouldIt: Bool) {
        switch shouldIt {
        case true:
            print(shouldIt)
        case false:
            navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    private func manageOnlyPatientsWithAnalyses () {
        FetchingManager.shared.fetchOnlyPatientsWithAnalyses { patients in
            self.patients = patients
            tableView.reloadData()
        }
    }
    
    private func manageOnlyPatientsWithAnalysesButtonPressed (buttonPressed: Bool) {
        switch buttonPressed {
        case true:
            tableView.refreshControl = nil
            manageOnlyPatientsWithAnalyses()
        case false:
            tableView.refreshControl = refresh
            FetchingManager.shared.fetchPatientsFromCoreData { patients in
                self.patients = patients
                self.tableView.reloadData()
            }
        }
    }
    
    private func configureNavigationBar () {
        let menuElement1 = UIAction(title: "Загрузить все данные", image: UIImage(systemName: "arrow.down.circle")?.withTintColor(.label, renderingMode: .alwaysOriginal))
        { [weak self] action in
            
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
    
    private func sortPatients (with filter: PatientFilter) {
  
        if patients.isEmpty {
            print("patients is empty")
        } else {
            switch filter {
            case .date:
                patients = patients.sorted { n1, n2 in
                    ascending ? n1.dateOfAdmission.getFormattedDateFromString()! > n2.dateOfAdmission.getFormattedDateFromString()! :
                    n1.dateOfAdmission.getFormattedDateFromString()! < n2.dateOfAdmission.getFormattedDateFromString()!
                }
                tableView.reloadData()
                ascending = !ascending
                
            case .name:
                patients = patients.sorted { n1, n2 in
                    ascending ? n1.name.first! > n2.name.first! : n1.name.first! < n2.name.first!
                }
                tableView.reloadData()
                ascending = !ascending
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

extension PatientsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBarText = searchController.searchBar.text
        updatePatientsWithSearchResults(using: searchBarText)
    }
    
    private func updatePatientsWithSearchResults(using: String?) {
        guard let using = using else {
            return
        }
        searchFilteredPatients = patients.filter({ $0.name.lowercased().contains(using.lowercased()) || $0.dateOfAdmission.lowercased().contains(using.lowercased())})
        tableView.reloadData()
    }
}


    


extension PatientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PatientsViewController.cellIdentidifer, for: indexPath)
        var contentConfiguration = cell.defaultContentConfiguration()
        
        let patient: Patient
        
        if isSearchFieldEditing {
            patient = searchFilteredPatients[indexPath.row]
        } else {
            patient = patients[indexPath.row]
        }
        contentConfiguration.text = patient.name
        contentConfiguration.secondaryText = "Поступил: \(patient.dateOfAdmission)"
        contentConfiguration.textProperties.font = .systemFont(ofSize: 15, weight: .semibold)
        contentConfiguration.secondaryTextProperties.font = .systemFont(ofSize: 12, weight: .light)
        cell.contentConfiguration = contentConfiguration
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchFieldEditing ? searchFilteredPatients.count : patients.count 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearchFieldEditing {
            presentResults(for: searchFilteredPatients[indexPath.row])
        } else {
            presentResults(for: patients[indexPath.row])
        }
    }
}

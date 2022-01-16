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
    
    //IBOutlets
    @IBOutlet var patientsTableView: UITableView!
    
    // NSManagedObjectContext for CoreData
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var container: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    //UISearch and RefrestControllers
    let search = UISearchController(searchResultsController: nil)
    let refresh = UIRefreshControl()
    
    //Variables
    var patients = [Patient]()
    var filteredPatients = [Patient]()
    var wards = [Int]()
    var analysesIds = [String]()
    var analysesData = [String]()
    var wardNumberToMoveTo = ""
    var titleForHeader : [String] {
        var titleForHeader = [String]()
        for i in 0...21 {
            titleForHeader.append(String(i))
        }
        return titleForHeader
    }
    var titleForHeadersInResultsVC = [String]()
    var analysesTableHeaderItems = [String]()
    var tableRowForResultsVC = [TableRowForResultsVC]()
    var isSearchBarEmpty : Bool {
        return search.searchBar.searchTextField.text?.isEmpty ?? true
    }
    var searchFieldIsEditing : Bool {
        return search.isActive && !isSearchBarEmpty
    }
    
    //View overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patientsTableView.delegate = self
        patientsTableView.dataSource = self
        getPatientsAndLabIds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupRefreshControl()
    }
    
    //Target function for UIRefreshControl
    @objc func refreshData (sender: UIRefreshControl) {
        getPatientsAndLabIds()
    }
    
    //Initializing UISearchController and RefreshControl
    func setupSearchController () {
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Искать..."
        search.searchBar.autocapitalizationType = .words
        navigationItem.searchController = search
        definesPresentationContext = true
    }
    
    func setupRefreshControl () {
        refresh.addTarget(self, action: #selector(PatientsViewController.refreshData(sender:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "Обновление данных...")
        patientsTableView.refreshControl = refresh
    }
    
    //Universal error presentation while fetching data
    func presentError (_ error: Error?) {
        guard let er = error else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            
            let alertController = UIAlertController(
                title: "К сожалению, произошла ошибка",
                message: "\(er.localizedDescription) \n Попытка загрузить кэш.",
                preferredStyle: .alert)
            self?.present(alertController, animated: true) {
                self?.cacheLoaded(title: "Кэш загружен", animationtype: .moveIn)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    alertController.dismiss(animated: true) {
                        self?.patientsTableView.refreshControl?.endRefreshing()
                        self?.cacheLoaded(title: "Cписок пациентов", animationtype: .fade)
                    }
                }
            }
        }
    }
    
    //Interface presentation of cache loading when no internet connection
    func cacheLoaded(title: String, animationtype: CATransitionType) {
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 0.2
        fadeTextAnimation.type = animationtype
        
        navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "")
        navigationItem.title = title
    }
    
    //Triggere while using searthTextField
    func filterContentForSearchTextField (_ textToSearch: String) {
        filteredPatients = patients.filter {$0.name.lowercased().contains(textToSearch.lowercased()) || $0.dateOfAdmission.lowercased().contains(textToSearch.lowercased())}
        patientsTableView.reloadData()
    }
    

    
}

//MARK: - PatientsTableView delegate methods and custom Table methods
extension PatientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 22
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchFieldIsEditing {
            return filteredPatients.filter { $0.ward.wardNumber == section}.count
        }
        return patients.filter { $0.ward.wardNumber == section }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.patientTableCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        let patient : Patient
        
        if searchFieldIsEditing {
            let filteredPatientsWardEqualSection = filteredPatients.filter { $0.ward.wardNumber == indexPath.section }
            patient = filteredPatientsWardEqualSection[indexPath.row]
        } else {
            let patientsWardEqualSection = patients.filter { $0.ward.wardNumber == indexPath.section }
            patient = patientsWardEqualSection[indexPath.row]
        }
        cell.textLabel?.text = patient.name
        cell.detailTextLabel?.text = patient.dateOfAdmission
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let filteredPatientsByWard = patients.filter{ $0.ward.wardNumber == section }
        if section == 0 {
            return "Нераспределенные"
        } else {
            if filteredPatientsByWard.isEmpty {
                return nil
            } else {
                return String("Палата № \(titleForHeader[section])")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let destinationTableVC = ResultsViewController()
        destinationTableVC.modalPresentationStyle = .fullScreen
        destinationTableVC.title = "Результаты"
        
        if searchFieldIsEditing {
            fetchAnalysesData(with: filteredPatients[indexPath.row].analysesIDs)
            destinationTableVC.headerForSection = titleForHeadersInResultsVC
            destinationTableVC.tableHeaderItems = analysesTableHeaderItems
            destinationTableVC.analysesResults = tableRowForResultsVC
        } else {
            fetchAnalysesData(with: patients[indexPath.row].analysesIDs)
        }
        
        navigationController?.pushViewController(destinationTableVC, animated: true)
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.numberOfRows(inSection: indexPath.section) == 0 ? 0 : 60
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
    
    
    //Custom trailing swipe actions
    func deleteRow(with style: UIContextualAction.Style, on: IndexPath, table: UITableView) -> UIContextualAction {
        let delete = UIContextualAction(style: style, title: "Перевести из палаты") { [weak self] action, view, completionHandler in
            view.backgroundColor = .systemRed
            let groupedPatientsByWard = self?.patients.filter{ $0.ward.wardNumber == on.section }
            if let patientToBeDeleted = groupedPatientsByWard?[on.row] {
                
                if self?.patients.contains(patientToBeDeleted) != nil {
                    self?.patients.removeAll { identicalPatient in
                        patientToBeDeleted == identicalPatient
                    }
                    
                    self?.patients.append(Patient(name: patientToBeDeleted.name, dateOfAdmission: patientToBeDeleted.dateOfAdmission, ward: Ward(wardNumber: 0, wardType: .fourMan), id: patientToBeDeleted.id, labIDs: patientToBeDeleted.analysesIDs))
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
        self.wardNumberToMoveTo = ""
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
        
        let action = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            
            if self?.wardNumberToMoveTo != "" {
                let groupedPatientsByWard = self?.patients.filter{ $0.ward.wardNumber == on.section }
                if let patientToBeMoved = groupedPatientsByWard?[on.row] {
                    if self?.patients.contains(patientToBeMoved) != nil {
                        self?.patients.removeAll { existingPatient in
                            patientToBeMoved == existingPatient
                        }
                        self?.patients.append(Patient(name: patientToBeMoved.name, dateOfAdmission: patientToBeMoved.dateOfAdmission, ward: Ward(wardNumber: Int(self!.wardNumberToMoveTo) ?? (patientToBeMoved.ward.wardNumber), wardType: .fourMan), id: patientToBeMoved.id, labIDs: patientToBeMoved.analysesIDs))
                    }
                }
                let indexPathToMoveTo = IndexPath(row: 0, section: Int(self!.wardNumberToMoveTo)!)
                table.moveRow(at: on, to: indexPathToMoveTo)
                do {
                    try self?.container.save()
                } catch {
                    fatalError("Error saving context.")
                }
            } else {
                return
            }
        })
        
        chooseWardToMoveToAlertVC.addAction(action)
        let move = UIContextualAction(style: style, title: "Перевести в палату") { [weak self] action, view, completionHandler in
            self?.present(chooseWardToMoveToAlertVC, animated: true) {
                completionHandler(true)
            }
        }
        move.backgroundColor = .systemBlue
        return move
    }
}



//MARK: - Fetch PatientsAndLabs Data
extension PatientsViewController {
    
    //Triggered on viewDidLoad to fetch patients and analyses ids'
    func getPatientsAndLabIds () {
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
            "Cookie" : "JSESSIONID=26F8D0FF63AAF6EEB29FCF6BDA4A9EA3; io=Vqhf80qtVIyhIrAkBNYU; login=TischenkoZI; PHPSESSID=houoor2ctkcjsmn1mabc6r1en3"
            
        ]
        
        let requestBody = "object=LpuSection&object_id=LpuSection_id&object_value=19219&level=0&LpuSection_id=19219&ARMType=stac&date=17.01.2022&filter_Person_F=&filter_Person_I=&filter_Person_O=&filter_PSNumCard=&filter_Person_BirthDay=&filter_MedStaffFact_id=&MedService_id=0&node=root"
        urlRequest.httpBody = requestBody.data(using: .utf8)
        
        let sessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: sessionConfig)
        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard error == nil else {
                self?.presentError(error)
                return
            }
            
            guard let unwrappedData = data else {
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode([ListOfPatients].self, from: unwrappedData)
                for patient in decodedData {
                    self?.fetchAnalysesIdsForPatient(with: patient.id!)
                    let dataForPatientsTableView = try SwiftSoup.parse(patient.name!)
                    let patientNames = try dataForPatientsTableView.getElementsByTag("span")
                    if !patientNames.isEmpty() {
                        let patient = Patient(name: try patientNames[0].text().capitalized, dateOfAdmission: try patientNames[1].text().trimmingCharacters(in: .whitespacesAndNewlines), id: patient.id!, labIDs: self!.analysesIds)
                        self?.patients.append(patient)
                    }
                }
                self?.analysesIds = [String]()
                
                DispatchQueue.main.async {
                    self?.patientsTableView.refreshControl?.endRefreshing()
                    self?.patientsTableView.reloadData()
                }
            } catch {
                self?.presentError(error)
            }
        }
        task.resume()
    }
    
    
    func fetchAnalysesIdsForPatient(with patientId: String){
        
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
                "Cookie" : "JSESSIONID=26F8D0FF63AAF6EEB29FCF6BDA4A9EA3; io=Vqhf80qtVIyhIrAkBNYU; login=TischenkoZI; PHPSESSID=houoor2ctkcjsmn1mabc6r1en3",
                
            ]
            
            let requestBody = "user_MedStaffFact_id=89902&scroll_value=EvnPS_\(patientId)&object=EvnPS&object_id=EvnPS_id&object_value=\(patientId)&archiveRecord=0&ARMType=stac&from_MZ=1&from_MSE=1"
            request.httpBody = requestBody.data(using: .utf8)
            return request
        }()
        
        let sessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: sessionConfig)
        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            
            guard error == nil else {
                self?.presentError(error)
                return
            }
            
            guard let receivedData = data else {
                return
            }
            
            let decoder = JSONDecoder()
            
            do{
                let decodedData = try decoder.decode(ListOfAnalysesIDs.self, from: receivedData)
                let html = try SwiftSoup.parse(decodedData.htmlData!)
                let evnUsluga = try html.getElementById("EvnUslugaStacList_\(patientId)")
                let tbody = try evnUsluga?.getElementsByTag("tbody")
                guard let values = try tbody?[0].getElementsByAttribute("value") else {
                    return
                }
                for value in values {
                    guard let analysisId = value.getAttributes()?.get(key: "value") else {
                        return
                    }
                    self?.analysesIds.append(analysisId)
                }
            } catch {
                self?.presentError(error)
            }
        }
        task.resume()
    }
    
    
    //Triggered when tableRow selected
    
    func fetchAnalysesData (with ids: [String]) {
        let urlForRequest: URL? = {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "crimea.promedweb.ru"
            urlComponents.queryItems = [
                URLQueryItem(name: "c", value: "EvnXml"),
                URLQueryItem(name: "m", value: "doLoadData")]
            return urlComponents.url
        }()
        
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
            "Cookie" : "io=sCcv3sqG_kbfCAeyAnzW; JSESSIONID=7D28392C267E9F0F94CBEA4505CACA97; login=TischenkoZI; PHPSESSID=houoor2ctkcjsmn1mabc6r1en3"
        ]
        for id in ids {
            
            let body = "XmlType_id=4&Evn_id=\(id)&EvnXml_id=31668158"
            let finalBody = body.data(using: .utf8)
            request.httpBody = finalBody
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                guard error == nil else {
                    self?.presentError(error)
                    return
                }
                
                if data != nil {
                    if let unwrappedData = data {
                        let decoder = JSONDecoder()
                        do {
                            let decodedData = try decoder.decode(AnalysisData.self, from: unwrappedData)
                            print(decodedData)
                            if self?.container.hasChanges != nil {
                                try self?.container.save()
                            }
                            let tableWithResultsData = try SwiftSoup.parse(decodedData.data!)
                            let analysisResults = try tableWithResultsData.getElementById("resolution")
                            if let headerTagsArray = try analysisResults?.getElementsByTag("th") {
                                for headerTag in headerTagsArray {
                                }
                            }
                            if let tableResultItems = try analysisResults?.getElementsByTag("tbody") {
                                for resultItem in tableResultItems {
                                    let tableRowTags = try resultItem.getElementsByTag("tr")
                                    for trtag in tableRowTags {
                                        let elementForTableRow = try trtag.text()
                                        self?.analysesData.append(elementForTableRow)
                                    }
                                }
                            }
                        } catch {
                            self?.presentError(error)
                        }
                    }
                }
            }
            
            task.resume()
        }
    }
}


//MARK: - TextField delegate methods
extension PatientsViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            if let textFieldText = textField.text {
                if Int(textFieldText)! > 21 {
                    let outOfRangeAlert = UIAlertController(title: "Указанное значение выше установленного диапазона", message: "Введите число от 1 до 21", preferredStyle: .alert)
                    DispatchQueue.main.async {
                        self.present(outOfRangeAlert, animated: true, completion: nil)
                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                            outOfRangeAlert.dismiss(animated: true, completion: nil)
                        }
                    }
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


//MARK: - CoreDataMethods
extension PatientsViewController {
    
    func fetchAnalysesDataFromCoreData (with id: String) {
        
        let request : NSFetchRequest<AnalysisData> = AnalysisData.fetchRequest()
        
        do {
            let results = try container.fetch(request)
            
            let html = try SwiftSoup.parse(results[0].data!)
            let spans = try html.getElementsContainingText("Дата взятия")
            for span in spans {
                if !span.ownText().isEmpty {
                    titleForHeadersInResultsVC.append(span.ownText().trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            let tableHeadItems = try html.getElementsByTag("th")
            for headerItem in tableHeadItems {
                analysesTableHeaderItems.append(try headerItem.text())
            }
            analysesTableHeaderItems.removeFirst()
            analysesTableHeaderItems.removeLast()
            let tableBody = try html.getElementsByTag("tbody")
            let tableRows = try tableBody[0].getElementsByTag("tr")
            for row in tableRows {
                
                let tbRow : TableRowForResultsVC = try {
                    let columns = try row.getElementsByTag("td")
                    var info = [String]()
                    for column in columns {
                        info.append(try column.text())
                    }
                    info.removeFirst()
                    info.removeLast()
                    let tableRow = TableRowForResultsVC(tableRow: info)
                    return tableRow
                }()
                tableRowForResultsVC.append(tbRow)
            }
        } catch {
            presentError(error)
        }
        
    }
    
}


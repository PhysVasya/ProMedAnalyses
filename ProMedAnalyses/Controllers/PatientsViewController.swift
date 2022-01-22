//
//  ViewController.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 13.12.2021.
//

import UIKit
import SwiftSoup
import CoreData

class PatientsViewController: UIViewController {
    
    
    //IBOutlets
    @IBOutlet var patientsTableView: UITableView!
    
    //UISearch and RefrestControllers
    let search = UISearchController(searchResultsController: nil)
    let refresh = UIRefreshControl()
    
    //Variables
    var patients = [Patient]()
    var filteredPatients = [Patient]()
    var wardNumberToMoveTo = ""
    var titleForHeader : [String] {
        var titleForHeader = [String]()
        for i in 0...21 {
            titleForHeader.append(String(i))
        }
        return titleForHeader
    }
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
        getPatientsAndEvnIds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRefreshControl()
    }
    
    //Target function for UIRefreshControl
    @objc func refreshData (sender: UIRefreshControl) {
        getPatientsAndEvnIds()
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
            let alertController = UIAlertController(title: "К сожалению, произошла ошибка", message: er.localizedDescription, preferredStyle: .alert)
            self?.present(alertController, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    alertController.dismiss(animated: true) {
                        self?.patientsTableView.refreshControl?.endRefreshing()
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
    
    func presentResultsVC (with analyses: [Analysis]) {
        DispatchQueue.main.async {
            let destinationVC = ResultsViewController()
            destinationVC.title = "Результаты"
            destinationVC.modalPresentationStyle = .fullScreen
            destinationVC.configureResultsVC(with: analyses)
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
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
        } else {
        return patients.filter { $0.ward.wardNumber == section }.count
        }
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
        
        if searchFieldIsEditing {
//            fetchAnalysesIds(for: filteredPatients[indexPath.row]) { [weak self] id in
//                self?.fetchAnalysesData(with: id)
//            }
            fetchLabDataFromCoreData(for: filteredPatients[indexPath.row])
        } else {
//            fetchAnalysesIds(for: patients[indexPath.row]) { [weak self] id in
//                self?.fetchAnalysesData(with: id)
//            }
            fetchLabDataFromCoreData(for: patients[indexPath.row])
        }
        
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
                    
                    self?.patients.append(Patient(name: patientToBeDeleted.name, dateOfAdmission: patientToBeDeleted.dateOfAdmission, ward: Ward(wardNumber: 0, wardType: .fourMan), patientID: patientToBeDeleted.patientID, evnID: patientToBeDeleted.evnID))
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
                        self?.patients.append(Patient(name: patientToBeMoved.name, dateOfAdmission: patientToBeMoved.dateOfAdmission, ward: Ward(wardNumber: Int(self!.wardNumberToMoveTo) ?? (patientToBeMoved.ward.wardNumber), wardType: .fourMan), patientID: patientToBeMoved.patientID, evnID: patientToBeMoved.evnID))
                    }
                }
                let indexPathToMoveTo = IndexPath(row: 0, section: Int(self!.wardNumberToMoveTo)!)
                table.moveRow(at: on, to: indexPathToMoveTo)
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
    func getPatientsAndEvnIds () {
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
            "Cookie" : "io=KVCvBBcjSxb3O8S6B650; JSESSIONID=4688D9084C9FE4D249FCE87FA86FD7E1; login=inf1; PHPSESSID=7e3slmbpotbcqaaq31cfffbj05"
            
        ]
        
        let requestBody = "object=LpuSection&object_id=LpuSection_id&object_value=19219&level=0&LpuSection_id=19219&ARMType=stac&date=19.01.2022&filter_Person_F=&filter_Person_I=&filter_Person_O=&filter_PSNumCard=&filter_Person_BirthDay=&filter_MedStaffFact_id=&MedService_id=0&node=root"
        urlRequest.httpBody = requestBody.data(using: .utf8)
        
        let sessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: sessionConfig)
        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard error == nil else {
                self?.presentError(error)
                self?.fetchPatientsFromCoreData()
                return
            }
            
            guard let unwrappedData = data else {
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode([FetchedListOfPatients].self, from: unwrappedData)
                for person in decodedData {
                    let dataForPatientsTableView = try SwiftSoup.parse(person.name!)
                    let patientNames = try dataForPatientsTableView.getElementsByTag("span")
                    if !patientNames.isEmpty() {
                        if let patientID = person.patientID,
                           let patientEvnId = person.evnID {
                            let patient = Patient(name: try patientNames[0].text().capitalized, dateOfAdmission: try patientNames[1].text().trimmingCharacters(in: .whitespacesAndNewlines), patientID: patientID, evnID: patientEvnId)
                            self?.patients.append(patient)
                        }
                    }
                }
                
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
    
    
    func fetchAnalysesIds(for patient: Patient, onCompletion: ((_ id: [String : String]) -> Void?)? = nil){
        
        var analysesIds = [String : String]()
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
                "Cookie" : "io=KVCvBBcjSxb3O8S6B650; JSESSIONID=4688D9084C9FE4D249FCE87FA86FD7E1; login=inf1; PHPSESSID=7e3slmbpotbcqaaq31cfffbj05",
                
            ]
            
            let requestBody = "user_MedStaffFact_id=89902&scroll_value=EvnPS_\(patient.patientID)&object=EvnPS&object_id=EvnPS_id&object_value=\(patient.patientID)&archiveRecord=0&ARMType=stac&from_MZ=1&from_MSE=1"
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
                let decodedData = try decoder.decode(FetchedListOfLabIDs.self, from: receivedData)
                guard let items = decodedData.map?.evnPS.item[0].children.evnSection.item[1].children.evnUslugaStac.item else {
                    return
                }
                for item in items  {
                    analysesIds[item.data.evnXMLID] = item.data.evnUslugaID
                }
                var values : [String] {
                    var v = [String]()
                    for value in analysesIds.values {
                        v.append(value)
                    }
                    return v
                }
                self?.savePatient(patientName: patient.name, patientID: patient.patientID, dateOfAdmission: patient.dateOfAdmission, evnID: patient.evnID, idsForAnalyses: values)
                onCompletion?(analysesIds)
                
            } catch {
                self?.presentError(error)
            }
        }
        task.resume()
    }
    
    
    //Triggered when tableRow selected
    func fetchAnalysesData (with ids: [String : String]) {
        var labFindings = [Analysis]()
        
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
            "Cookie" : "io=KVCvBBcjSxb3O8S6B650; JSESSIONID=4688D9084C9FE4D249FCE87FA86FD7E1; login=inf1; PHPSESSID=7e3slmbpotbcqaaq31cfffbj05"
        ]
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        for id in ids {
            let body = "XmlType_id=4&Evn_id=\(id.value)&EvnXml_id=\(id.key)"
            let finalBody = body.data(using: .utf8)
            request.httpBody = finalBody
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                guard error == nil else {
                    self?.presentError(error)
                    return
                }
                
                guard let receivedLabData = data else {
                    return
                }
                
                let decoder = JSONDecoder()
                var collectionDate = String()
                var analysisHeaderItems = [String]()
                var analysisItems = [[String]]()
                
                do {
                    let decodedData = try decoder.decode(FetchedLabData.self, from: receivedLabData)
                    let html = try SwiftSoup.parse(decodedData.data!)
                    let spans = try html.getElementsContainingText("Дата взятия")
                    
                    //Get date of analysis
                    for span in spans {
                        if !span.ownText().isEmpty {
                            collectionDate = span.ownText().trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    
                    //Get header of analysis (Название, норм.диапазон и тп)
                    let tableHeadItems = try html.getElementsByTag("th")
                    for headerItem in tableHeadItems {
                        analysisHeaderItems.append(try headerItem.text())
                    }
                    analysisHeaderItems.removeFirst()
                    analysisHeaderItems.removeLast()
                    
                    let tableBody = try html.getElementsByTag("tbody")
                    let tableRows = try tableBody[0].getElementsByTag("tr")
                    for row in tableRows {
                        let tbRow : [String] = try {
                            let columns = try row.getElementsByTag("td")
                            var info = [String]()
                            for column in columns {
                                info.append(try column.text())
                            }
                            info.removeFirst()
                            info.removeLast()
                            return info
                        }()
                        analysisItems.append(tbRow)
                    }
                    
                    print(analysisItems)
                    //                    self?.saveLabData(data: analysisItems, date: collectionDate, header: analysisHeaderItems, labID: id.value, xmlID: id.key)
                    let analysis = Analysis(rows: analysisItems, dateForHeaderInSection: collectionDate, headerForAnalysis: analysisHeaderItems)
                    labFindings.append(analysis)
                    
                } catch {
                    self?.presentError(error)
                }
            }
            task.resume()
        }
        self.presentResultsVC(with: labFindings)
    }
}


//MARK: - TextField delegate methods
extension PatientsViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            if let textFieldText = textField.text {
                if Int(textFieldText)! > 21 {
                    let outOfRangeAlert = UIAlertController(title: "Указанное значение выше установленного диапазона", message: "Введите число от 1 до 21", preferredStyle: .alert)
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


//MARK: - CoreDataMethods
extension PatientsViewController {
    func savePatient (patientName: String, patientID: String, dateOfAdmission: String, evnID: String, idsForAnalyses: [String]) {
        
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            // NSManagedObjectContext for CoreData
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //Creating an instance of ManagedObject
            let entity = NSEntityDescription.entity(forEntityName: "ManagedPatient", in: managedContext)!
            let person = NSManagedObject(entity: entity, insertInto: managedContext) as! ManagedPatient
            person.patientName = patientName
            person.patientID = patientID
            person.dateOfAdmission = dateOfAdmission
            person.labID = evnID
            person.idsToFetchAnalyses = idsForAnalyses
            
            if managedContext.hasChanges {
                do {
                    try managedContext.save()
                } catch {
                    self.presentError(error)
                }
            }
        }
    }
    
    func saveLabData (data: [[String]], date: String, header: [String], labID: String, xmlID: String) {
        
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //Creating a new instance of ManagedObject
            let entity = NSEntityDescription.entity(forEntityName: "ManagedLabData", in: managedContext)!
            let labData = NSManagedObject(entity: entity, insertInto: managedContext) as! ManagedLabData
            labData.labID = labID
            labData.data = data
            labData.date = date
            labData.header = header
            labData.xmlID = xmlID
            
            if managedContext.hasChanges {
                do {
                    try managedContext.save()
                } catch {
                    self.presentError(error)
                }
            }
        }
    }
    
    func fetchLabDataFromCoreData (for patient: Patient) {
        
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            
            let request : NSFetchRequest<ManagedLabData> = ManagedLabData.fetchRequest()
            var labFindings = [Analysis]()
            do {
            let fetchAnalysesFromCoreData = try context.fetch(request)
                
                for fetchedAnalysis in fetchAnalysesFromCoreData {
                    if patient.labIDs.contains(fetchedAnalysis.labID!) {
                        let analysis = Analysis(rows: fetchedAnalysis.data!, dateForHeaderInSection: fetchedAnalysis.date!, headerForAnalysis: fetchedAnalysis.header!)
                        labFindings.append(analysis)
                    } else {
                        print("There are no saved analyses for this patient.")
                        return
                    }
                }
//                print(labFindings)
                self.presentResultsVC(with: labFindings)
            } catch {
                self.presentError(error)
            }

        }
    }
    
    func fetchPatientsFromCoreData () {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            var fetchedPatients = [Patient]()
            
            let request : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
            do {
                let fetchedPatientsFromCoreData = try context.fetch(request)
                for fetchedPatient in fetchedPatientsFromCoreData {
                    let patient = Patient(name: fetchedPatient.patientName, dateOfAdmission: fetchedPatient.dateOfAdmission, patientID: fetchedPatient.patientID, evnID: fetchedPatient.labID, labIDs: fetchedPatient.idsToFetchAnalyses)
                    fetchedPatients.append(patient)
                }
                self.patients = fetchedPatients
//                print(self.patients.last!.labIDs)
                self.patientsTableView.reloadData()
            } catch {
                self.presentError(error)
            }
            
        }
    }
}



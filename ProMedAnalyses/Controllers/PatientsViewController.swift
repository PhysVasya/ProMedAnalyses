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
    
    var phpSessID: String?
    var ioCookies: String?
    
    var login: String?
    var link: String?
    
    let defaults = UserDefaults.standard
    
    //UISearch and RefrestControllers
    let search = UISearchController(searchResultsController: nil)
    let refresh = UIRefreshControl()
    
    //Variables
    let context = CoreDataStack(modelName: "ProMedAnalyses").managedContext
    
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
        navigationController?.navigationBar.isHidden = false
   
        //        print(phpSessID)
        patientsTableView?.delegate = self
        patientsTableView?.dataSource = self
        getCookies { [weak self] in
            self?.getPatientsAndEvnIds(with: self?.phpSessID, ioCookie: self?.ioCookies)
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
        patientsTableView?.refreshControl = refresh
    }
    
    //Interface presentation of cache loading when no internet connection
    func cacheLoaded(title: String, animationtype: [CATransitionType], _ completionHandler : (()-> Void?)? = nil) {
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 0.2
        fadeTextAnimation.type = animationtype[0]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "")
            self.navigationItem.title = title
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                fadeTextAnimation.type = animationtype[1]
                self.navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "")
                self.navigationItem.title = "Список пациентов"
            }
            completionHandler?()
        }
        
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
        
        return 21
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
        let cell = tableView.dequeueReusableCell(withIdentifier: K.patientTableCell, for: indexPath)
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
        content.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12, weight: .light)
        
        content.text = patient.name
        content.secondaryText = patient.dateOfAdmission
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
            return String("Палата № \(titleForHeader[section])")
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return patients.filter { $0.ward.wardNumber == section }.isEmpty ? CGFloat.leastNonzeroMagnitude : 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return patients.filter{ $0.ward.wardNumber == section}.isEmpty ? CGFloat.leastNonzeroMagnitude : 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if searchFieldIsEditing {
            fetchAnalysesIds(for: filteredPatients[indexPath.row]) { [weak self] id in
                self?.fetchAnalysesData(with: id)
            }
        } else {
            let filteredPatientsByWard = patients.filter{ $0.ward.wardNumber == indexPath.section }
            fetchAnalysesIds(for: filteredPatientsByWard[indexPath.row]) { [weak self] id in
                self?.fetchAnalysesData(with: id)
            }
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
            
            let groupedPatientsByWard = self?.patients.filter{ $0.ward.wardNumber == on.section }
            if let patientToBeMoved = groupedPatientsByWard?[on.row] {
                if self?.patients.contains(patientToBeMoved) != nil {
                    self?.patients.removeAll { existingPatient in
                        patientToBeMoved == existingPatient
                    }
                    self?.patients.append(Patient(name: patientToBeMoved.name, dateOfAdmission: patientToBeMoved.dateOfAdmission, ward: Ward(wardNumber: Int(self!.wardNumberToMoveTo)! , wardType: .fourMan), patientID: patientToBeMoved.patientID, evnID: patientToBeMoved.evnID, labIDs: patientToBeMoved.labIDs))
                    self?.savePatient(patientName: patientToBeMoved.name, patientID: patientToBeMoved.patientID, dateOfAdmission: patientToBeMoved.dateOfAdmission, evnID: patientToBeMoved.evnID, idsForAnalyses: patientToBeMoved.labIDs, wardNumber: Int16(self!.wardNumberToMoveTo)!)
                    
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



//MARK: - Fetch PatientsAndLabs Data
extension PatientsViewController {
    
    
    func getCookies (_ completionHandler: (()->Void?)? = nil)  {
        
        if phpSessID != nil && ioCookies != nil {
            getPatientsAndEvnIds(with: phpSessID, ioCookie: ioCookies)
        } else {
            
            let url1 = URL(string: "https://crimea.promedweb.ru/?c=portal&m=udp")
            let url2 = URL(string: "https://crimea.promedweb.ru:9991/socket.io/?EIO=3&transport=polling&t=1644374548290-0")
                            
                let task1 = URLSession.shared.dataTask(with: url1!) { [weak self] data, response, error in
                    guard error == nil else {
                        K.presentError(self, error: error, completion: {
                            self?.patientsTableView?.refreshControl?.endRefreshing()
                        })
                        self?.cacheLoaded(title: "Кэш загружен", animationtype: [.push, .fade], {
                            self?.fetchPatientsFromCoreData()
                        })
                        return
                    }
                    
                    guard let urlResponse = response?.url,
                          let httpResponse = response as? HTTPURLResponse,
                          let fields = httpResponse.allHeaderFields as? [String : String] else {
                              return
                          }
                    
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: urlResponse)
                    for cookie in cookies {
                        var cookieProps = [HTTPCookiePropertyKey : Any]()
                        cookieProps[.value] = cookie.value
                        self?.phpSessID = cookieProps[.value] as? String
                        print("\(cookieProps[.value] ?? "LEL")")
                        
                    }
                    
                }
            
            let task2 = URLSession.shared.dataTask(with: url2!) { data, response, error in
                guard error == nil else {
                    return
                }
                
                guard let urlResponse = response?.url,
                      let httpResponse = response as? HTTPURLResponse,
                      let fields = httpResponse.allHeaderFields as? [String : String] else {
                          return
                      }
                
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: urlResponse)
                for cookie in cookies {
                    var cookieProps = [HTTPCookiePropertyKey : Any]()
                    cookieProps[.value] = cookie.value
                    self.ioCookies = cookieProps[.value] as? String
                    print("\(cookieProps[.value] ?? "LEL")")
                    
                }
                
            }
                task1.resume()
            task2.resume()
            defaults.set(login, forKey: "Login")
            defaults.set(link, forKey: "Link")
        }
    }
    
    
    //Triggered on viewDidLoad to fetch patients and analyses ids'
    func getPatientsAndEvnIds (with phpSessID: String? = nil, ioCookie: String? = nil) {
        var urlForPatientRequest : URL? {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "crimea.promedweb.ru"
            urlComponents.queryItems = [
                URLQueryItem(name: "c", value: "EvnSection"),
                URLQueryItem(name: "m", value: "getSectionTreeData")
            ]
            return urlComponents.url
        }
        
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
            "Cookie" : "io=\(ioCookie); JSESSIONID=D6DA62846F076AA21E01BE91BAD4615D; login=\(login); PHPSESSID=\(phpSessID)"
            
        ]
        
        let date = Date()
        let requestBody = "object=LpuSection&object_id=LpuSection_id&object_value=19219&level=0&LpuSection_id=19219&ARMType=stac&date=\(date.getFormattedDate())&filter_Person_F=&filter_Person_I=&filter_Person_O=&filter_PSNumCard=&filter_Person_BirthDay=&filter_MedStaffFact_id=&MedService_id=0&node=root"
        urlRequest.httpBody = requestBody.data(using: .utf8)
        
        let sessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: sessionConfig)
        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard error == nil else {
                K.presentError(self, error: error, completion: {
                    self?.patientsTableView?.refreshControl?.endRefreshing()
                })
                self?.cacheLoaded(title: "Кэш загружен", animationtype: [.push, .fade], {
                    self?.fetchPatientsFromCoreData()
                })
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
                K.presentError(self, error: error) {
                    self?.patientsTableView?.refreshControl?.endRefreshing()
                }
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
                "Cookie" : "io=NvbvsL6z7_C5JiD6DbAs; JSESSIONID=D6DA62846F076AA21E01BE91BAD4615D; login=\(login); PHPSESSID=7velsds6e30ecgivsujn2chjc7",
                
            ]
            
            let requestBody = "user_MedStaffFact_id=89902&scroll_value=EvnPS_\(patient.patientID)&object=EvnPS&object_id=EvnPS_id&object_value=\(patient.patientID)&archiveRecord=0&ARMType=stac&from_MZ=1&from_MSE=1"
            request.httpBody = requestBody.data(using: .utf8)
            return request
        }()
        
        let sessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: sessionConfig)
        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            
            guard error == nil else {
                self?.fetchLabDataFromCoreData(for: patient)
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
                self?.savePatient(patientName: patient.name, patientID: patient.patientID, dateOfAdmission: patient.dateOfAdmission, evnID: patient.evnID, idsForAnalyses: values, wardNumber: Int16(patient.ward.wardNumber))
                onCompletion?(analysesIds)
                
            } catch {
                K.presentError(self, error: error) {
                    self?.patientsTableView?.refreshControl?.endRefreshing()
                }
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
                URLQueryItem(name: "m", value: "doLoadData")
            ]
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
            "Cookie" : "io=NvbvsL6z7_C5JiD6DbAs; JSESSIONID=D6DA62846F076AA21E01BE91BAD4615D; login=\(login); PHPSESSID=7velsds6e30ecgivsujn2chjc7"
        ]
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        for id in ids {
            let body = "XmlType_id=4&Evn_id=\(id.value)&EvnXml_id=\(id.key)"
            let finalBody = body.data(using: .utf8)
            request.httpBody = finalBody
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                guard error == nil else {
                    K.presentError(self, error: error) {
                        self?.patientsTableView?.refreshControl?.endRefreshing()
                    }
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
                    
                    self?.saveLabData(data: analysisItems, date: collectionDate, header: analysisHeaderItems, labID: id.value, xmlID: id.key)
                    let analysis = Analysis(rows: analysisItems, dateForHeaderInSection: collectionDate, headerForAnalysis: analysisHeaderItems)
                    labFindings.append(analysis)
                    
                } catch {
                    K.presentError(self, error: error) {
                        self?.patientsTableView?.refreshControl?.endRefreshing()
                        
                    }
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
    func savePatient (patientName: String, patientID: String, dateOfAdmission: String, evnID: String, idsForAnalyses: [String], wardNumber: Int16) {
        
        DispatchQueue.main.async {
            
            //Creating an instance of ManagedObject
            guard let entity = NSEntityDescription.entity(forEntityName: K.CoreData.managedPatient, in: self.context) else {
                return
            }
            let person = NSManagedObject(entity: entity, insertInto: self.context) as! ManagedPatient
            person.patientName = patientName
            person.patientID = patientID
            person.dateOfAdmission = dateOfAdmission
            person.labID = evnID
            person.idsToFetchAnalyses = idsForAnalyses
            person.wardNumber = wardNumber
            
            do {
                try self.context.save()
            } catch {
                K.presentError(self, error: error, completion: nil)
                
            }
        }
    }
    
    func saveLabData (data: [[String]], date: String, header: [String], labID: String, xmlID: String) {
        
        DispatchQueue.main.async {
            //Creating a new instance of ManagedObject
            guard let entity = NSEntityDescription.entity(forEntityName: K.CoreData.managedLabData, in: self.context) else {
                return
            }
            let labData = NSManagedObject(entity: entity, insertInto: self.context) as! ManagedLabData
            labData.labID = labID
            labData.data = data
            labData.date = date
            labData.header = header
            labData.xmlID = xmlID
            
                do {
                    try self.context.save()
                } catch {
                    K.presentError(self, error: error, completion: nil)
                }
            
        }
    }
    
    func fetchLabDataFromCoreData (for patient: Patient) {
        
        DispatchQueue.main.async {
            let request : NSFetchRequest<ManagedLabData> = ManagedLabData.fetchRequest()
            var labFindings = [Analysis]()
            do {
                let fetchAnalysesFromCoreData = try self.context.fetch(request)
                
                for fetchedAnalysis in fetchAnalysesFromCoreData {
                    
                    if patient.labIDs.contains(fetchedAnalysis.labID!) {
                        let analysis = Analysis(rows: fetchedAnalysis.data!, dateForHeaderInSection: fetchedAnalysis.date!, headerForAnalysis: fetchedAnalysis.header!)
                        labFindings.append(analysis)
                        
                    }
                }
                self.presentResultsVC(with: labFindings)
            } catch {
                K.presentError(self, error: error)
            }
            
        }
    }
    
    func fetchPatientsFromCoreData () {
        var fetchedPatients = [Patient]()
        let request : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        do {
            let fetchedPatientsFromCoreData = try self.context.fetch(request)
            for fetchedPatient in fetchedPatientsFromCoreData {
                let patient = Patient(name: fetchedPatient.patientName!, dateOfAdmission: fetchedPatient.dateOfAdmission!, patientID: fetchedPatient.patientID!, evnID: fetchedPatient.labID!, labIDs: fetchedPatient.idsToFetchAnalyses!)
                fetchedPatients.append(patient)
            }
            self.patients = fetchedPatients
            self.patientsTableView?.reloadData()
        } catch {
            K.presentError(self, error: error) {
                self.patientsTableView?.refreshControl?.endRefreshing()
                
            }
        }
        
    }
    
}


extension Date {
    
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}

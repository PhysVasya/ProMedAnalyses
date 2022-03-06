//
//  ManagingFetching.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 19.02.2022.
//

import Foundation
import SwiftSoup
import CoreData


class FetchingManager {
    
    static let shared = FetchingManager(hasConnection: (UIApplication.shared.delegate as! AppDelegate).connectionIsSatisfied)
    
    private var hasConnection: Bool?
    private var patients = [Patient]()
    private var labFindings = [Analysis]()

    private let context = CoreDataStack(modelName: "ProMedAnalyses").managedContext

    private init (hasConnection: Bool?) {
        self.hasConnection = hasConnection
    }
    

    //MARK: - FetchingPatientsMethods
    
        //Triggered on viewDidLoad to fetch patients and analyses ids'
    public func getPatientsAndEvnIds (completionHandler: @escaping (_: [Patient]) -> Void) {
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
            
        guard let url = urlForPatientRequest,
                let io = AuthorizationManager.shared.ioCookie,
                let jSessionID = AuthorizationManager.shared.jSessionID,
                let phpSessionID = AuthorizationManager.shared.sessionID else {
                return
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.allHTTPHeaderFields = [
                "Origin" : "https://crimea.promedweb.ru",
                "Referer" : "https://crimea.promedweb.ru/?c=promed",
                "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15",
                "Host":"crimea.promedweb.ru",
                "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "Accept-Language": "en-GB,en;q=0.9",
                "Accept-Encoding": "gzip, deflate, br",
                "Connection": "keep-alive",
                "X-Requested-With" : "XMLHttpRequest",
                "Content-Length" : "260",
                "Cookie" : "io=\(io); JSESSIONID=\(jSessionID); login=inf1; PHPSESSID=\(phpSessionID)"
            ]
            
            let date = Date()
            let requestBody = "object=LpuSection&object_id=LpuSection_id&object_value=19219&level=0&LpuSection_id=19219&ARMType=stac&date=\(date.getFormattedDate())&filter_Person_F=&filter_Person_I=&filter_Person_O=&filter_PSNumCard=&filter_Person_BirthDay=&filter_MedStaffFact_id=&MedService_id=0&node=root"
            urlRequest.httpBody = requestBody.data(using: .utf8)
            
            let sessionConfig = URLSessionConfiguration.default
            let urlSession = URLSession(configuration: sessionConfig)
            let task = urlSession.dataTask(with: urlRequest) { data, response, error in
                guard error == nil else {
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
                                self.patients.append(patient)
                                completionHandler(self.patients)
                                self.savePatient(patientName: patient.name, patientID: patient.patientID, dateOfAdmission: patient.dateOfAdmission, evnID: patient.evnID, idsForAnalyses: patient.labIDs, wardNumber: Int16(patient.ward.wardNumber))
                            }
                        }
                    }
                    
                } catch {
                   print("Error fetching patients from web \(error)")
                }
            }
            task.resume()
        }
        
        
    public func fetchPatientsFromCoreData (completionHandler: (_ : [Patient])->Void) {
            var fetchedPatients = [Patient]()
            let request : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
            do {
                let fetchedPatientsFromCoreData = try self.context.fetch(request)
                for fetchedPatient in fetchedPatientsFromCoreData {
                    let patient = Patient(name: fetchedPatient.patientName!, dateOfAdmission: fetchedPatient.dateOfAdmission!, ward: Ward(wardNumber: Int(fetchedPatient.wardNumber), wardType: .fourMan), patientID: fetchedPatient.patientID!, evnID: fetchedPatient.labID!, labIDs: fetchedPatient.idsToFetchAnalyses!)
                    fetchedPatients.append(patient)
                }
                patients = fetchedPatients
                completionHandler(fetchedPatients)
                
            } catch {
               
            }
            
        }
    
    
    //MARK: - Getting analyses data methods
    
    private func fetchLabIDs(for patient: Patient, onCompletion: @escaping (_ id: [String : String]) -> Void?){
        
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
        
        guard let url = urlForRequest,
              let io = AuthorizationManager.shared.ioCookie,
              let jSessionID = AuthorizationManager.shared.jSessionID,
              let phpSessionID = AuthorizationManager.shared.sessionID,
              let login = AuthorizationManager.shared.login else {
                  return
              }
        
        let urlRequest : URLRequest = {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "Origin" : "https://crimea.promedweb.ru",
                "Referer" : "https://crimea.promedweb.ru/?c=promed",
                "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15",
                "Host":"crimea.promedweb.ru",
                "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "Accept-Language": "en-GB,en;q=0.9",
                "Accept-Encoding": "gzip, deflate, br",
                "Connection": "keep-alive",
                "Content-Length" : "172",
                "Cookie" : "io=\(io); JSESSIONID=\(jSessionID); login=\(login); PHPSESSID=\(phpSessionID)"
            ]
            
            let requestBody = "user_MedStaffFact_id=89902&scroll_value=EvnPS_\(patient.patientID)&object=EvnPS&object_id=EvnPS_id&object_value=\(patient.patientID)&archiveRecord=0&ARMType=stac&from_MZ=1&from_MSE=1"
            request.httpBody = requestBody.data(using: .utf8)
            return request
        }()
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil, let receivedData = data else {
                print("Error fetching labIDs: \(String(describing: error))")
                return
            }
            
            do{
                let decodedData = try JSONDecoder().decode(FetchedListOfLabIDs.self, from: receivedData)
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
                self.savePatient(patientName: patient.name, patientID: patient.patientID, dateOfAdmission: patient.dateOfAdmission, evnID: patient.evnID, idsForAnalyses: values, wardNumber: Int16(patient.ward.wardNumber))
                onCompletion(analysesIds)
            } catch let error {
                print("Error fetching labIDs: \(error)")
            }
        }.resume()
    }
    
    private func fetchAnalysesData (with ids: [String : String], completionHandler: @escaping (_ : [Analysis]?)->Void) {

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
        
        guard let url = urlForRequest,
              let io = AuthorizationManager.shared.ioCookie,
              let jSessionID = AuthorizationManager.shared.jSessionID,
              let phpSessionID = AuthorizationManager.shared.sessionID,
              let login = AuthorizationManager.shared.login else {
                  return
              }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
            "Origin" : "https://crimea.promedweb.ru",
            "Referer" : "https://crimea.promedweb.ru/?c=promed",
            "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15",
            "Host":"crimea.promedweb.ru",
            "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-GB,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive",
            "Content-Length" : "54",
            "Cookie" : "io=\(io); JSESSIONID=\(jSessionID); login=\(login); PHPSESSID=\(phpSessionID)"
        ]
        
        for id in ids {
            let body = "XmlType_id=4&Evn_id=\(id.value)&EvnXml_id=\(id.key)"
            let finalBody = body.data(using: .utf8)
            request.httpBody = finalBody
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil, let receivedLabData = data  else {
                    print("Error fetching analyses data \(String(describing: error?.localizedDescription))")
                    return
                }
                
                var collectionDate = String()
                var analysisHeaderItems = [String]()
                var analysisItems = [[String]]()
                
                do {
                    let decodedData = try JSONDecoder().decode(FetchedLabData.self, from: receivedLabData)
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
                    
                    self.saveLabData(data: analysisItems, date: collectionDate, header: analysisHeaderItems, labID: id.value, xmlID: id.key)
                    let analysis = Analysis(rows: analysisItems, dateForHeaderInSection: collectionDate, headerForAnalysis: analysisHeaderItems)
                    self.labFindings.append(analysis)
                    
                } catch let error {
                    print("Error fetching analyses data \(String(describing: error.localizedDescription))")
                }
            }.resume()
        }
        completionHandler(labFindings)
    }
    
    public func downloadLabData (for patient: Patient, completionHanlder: @escaping (_ labData: [Analysis]) -> Void) {
        fetchLabIDs(for: patient) { [weak self] id in
            self?.fetchAnalysesData(with: id) { analyses in
                guard let analyses = analyses else {
                    return
                }
                completionHanlder(analyses)
            }
        }
    }
    
    
    public func fetchLabDataFromCoreData (for patient: Patient, predicateArg: String? = nil, completionHandler: @escaping (_ : [Analysis]) -> Void) {
                    
            DispatchQueue.main.async {
                let request : NSFetchRequest<ManagedLabData> = ManagedLabData.fetchRequest()
                if let arg = predicateArg {
                    request.predicate = NSPredicate(format: "SELF CONTAINS %@", "\(arg)")
                }
                var labFindings = [Analysis]()
                do {
                    let fetchAnalysesFromCoreData = try self.context.fetch(request)
                    
                    for fetchedAnalysis in fetchAnalysesFromCoreData {
                        
                        if patient.labIDs.contains(fetchedAnalysis.labID!) {
                            let analysis = Analysis(rows: fetchedAnalysis.data!, dateForHeaderInSection: fetchedAnalysis.date!, headerForAnalysis: fetchedAnalysis.header!)
                            labFindings.append(analysis)
                            
                        }
                    }
                    completionHandler(labFindings)
                } catch let error {
                    print("Error fetching analyses data from coredata: \(error.localizedDescription)")
                }
                
            }
        }
    
    //MARK: - CoreData Methods
       
        public func savePatient (patientName: String, patientID: String, dateOfAdmission: String, evnID: String, idsForAnalyses: [String], wardNumber: Int16) {
            
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
                } catch let error {
                    print("Error saving patient: \(error)")
                }
            }
        }
    
    func deletePatient (patientName: String, patientID: String, dateOfAdmission: String, evnID: String, idsForAnalyses: [String], wardNumber: Int16) {
        
        guard let entity = NSEntityDescription.entity(forEntityName: K.CoreData.managedPatient, in: context) else {
            return
        }
        
        let person = NSManagedObject(entity: entity, insertInto: context) as! ManagedPatient
        person.patientName = patientName
        person.patientID = patientID
        person.dateOfAdmission = dateOfAdmission
        person.labID = evnID
        person.idsToFetchAnalyses = idsForAnalyses
        person.wardNumber = wardNumber
        
        context.delete(person)
        
        do {
            try context.save()
        } catch let error {
            print("Error deleting and saving data: \(error)")
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
                } catch let error {
                    print("Error saving lab data: \(error)")
                }
            }
        }
    
}



//
//  APICallManager.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 05.03.2022.
//

import Foundation
import SwiftSoup
import CoreData

struct APICallManager {
    
    static let shared = APICallManager()
    
    private let patientFetch: NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
    
    private init () {}
    
    enum APICallErrors: String, Error {
        case errorDownloadingPatients = "Error downloading patients"
        case errorDownloadingLabIDs = "Error downloading lab IDs"
        case errorDownloadnigLabData = "Error downloading lab data"
    }
    
    public func getPatientsAndEvnIds (completion: @escaping (Bool) -> Void) {
        
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
                  completion(false)
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
        
        let requestBody = "object=LpuSection&object_id=LpuSection_id&object_value=19219&level=0&LpuSection_id=19219&ARMType=stac&date=\(Date().getFormattedDate())&filter_Person_F=&filter_Person_I=&filter_Person_O=&filter_PSNumCard=&filter_Person_BirthDay=&filter_MedStaffFact_id=&MedService_id=0&node=root"
        urlRequest.httpBody = requestBody.data(using: .utf8)
        
        let urlConfig = URLSessionConfiguration.default
        urlConfig.timeoutIntervalForResource = 5
        urlConfig.timeoutIntervalForRequest = 5
        let urlSession = URLSession(configuration: urlConfig)
        
        
        urlSession.dataTask(with: urlRequest) { data, response, error in
            guard error == nil, let unwrappedData = data else {
                print("\(APICallErrors.errorDownloadingPatients.rawValue) : \(String(describing: error))")
                completion(false)
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode([FetchedListOfPatients].self, from: unwrappedData)
                for person in decodedData {
                    let dataForPatientsTableView = try SwiftSoup.parse(person.name!)
                    let patientNames = try dataForPatientsTableView.getElementsByTag("span")
                    if !patientNames.isEmpty() {
                    
                        if let patientID = person.patientID,
                           let patientDateOfAdmission = person.dateOfAdmission,
                           let patientBirthday = person.birthday,
                           let patientSex = person.sex
                        {
                            let patient = Patient(name: try patientNames[0].text().capitalized, dateOfAdmission: patientDateOfAdmission, ward: Ward(wardNumber: 0, wardType: .fourMan), patientID: patientID, birthday: patientBirthday, sex: patientSex)
                            FetchingManager.shared.checkPatientAndSaveIfNeeded(patient: patient)
                        }
                    }
                }
                completion(true)
            } catch let error {
                print("\(APICallErrors.errorDownloadingPatients.rawValue) : \(error)")
                completion(false)
                
            }
        }.resume()
    }
    
    
    private func downloadLabIDs(for patient: Patient) async -> [FetchedLabIDs]? {
        
        var analysesIds = [FetchedLabIDs]()
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
            return nil
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
        
        return await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: urlRequest) { data1, response, error in
                guard error == nil, let receivedData = data1 else {
                    print("\(APICallErrors.errorDownloadingLabIDs.rawValue): \(String(describing: error))")
                    return
                }
                
                do{
                    
                    FetchingManager.shared.checkPatientAndSaveIfNeeded(patient: patient) { result in
                        switch result {
                        case .success(let patientExists):
                            FetchingManager.shared.sharedPatient = patientExists
                        case .failure(let error):
                            print("Error checking patient \(error)")
                        }
                    }
                    
                    let decodedData = try JSONDecoder().decode(FetchedListOfLabIDs.self, from: receivedData)
                    guard let items = decodedData.map?.evnPS.item[0].children.evnSection.item[1].children.evnUslugaStac.item else {
                        return
                    }
                    
                    for item in items  {
                        let analysisID = FetchedLabIDs(evnXMLID: item.data.evnXMLID, evnUslugaID: item.data.evnUslugaID, uslugaName: item.data.uslugaName, evnUslugaDate: item.data.evnUslugaDate)
                        analysesIds.append(analysisID)
                    }
                    continuation.resume(returning: analysesIds)
                } catch let error {
                    print("\(APICallErrors.errorDownloadingLabIDs.rawValue) : \(error)")
                }
            }.resume()
        }
    }
    
    private func downloadLabData (with ids: [FetchedLabIDs]) async -> [AnalysisType]? {
        
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
            return nil
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
        var labFindings = [AnalysisType]()
        let dispatchGroup = DispatchGroup()
        
        for id in ids {
            dispatchGroup.enter()
            let body = "XmlType_id=4&Evn_id=\(id.evnUslugaID)&EvnXml_id=\(id.evnXMLID)"
            let finalBody = body.data(using: .utf8)
            request.httpBody = finalBody
            
            URLSession.shared.dataTask(with: request) { data1, response, error in
                defer { dispatchGroup.leave() }
                guard error == nil, let receivedLabData = data1  else {
                    print("\(APICallErrors.errorDownloadnigLabData.rawValue) : \(String(describing: error?.localizedDescription))")
                    return
                }
                
                var analysisItems = [[String]]()
                
                do {
                    let decodedData = try JSONDecoder().decode(FetchedLabData.self, from: receivedLabData)
                    let html = try SwiftSoup.parse(decodedData.data!)
                    
                    
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
                    
                    let analysis = AnalysisDataModel(data: analysisItems, date: id.evnUslugaDate)
                    let analysisType = AnalysisType(analysis: analysis, evnUslugaID: id.evnUslugaID, evnXMLID: id.evnXMLID, name: id.uslugaName, date: id.evnUslugaDate)
                    labFindings.append(analysisType)
                    
                } catch let error {
                    print("\(APICallErrors.errorDownloadnigLabData.rawValue) : \(String(describing: error.localizedDescription))")
                }
            }.resume()
        }
        return await withCheckedContinuation { continuation in
            dispatchGroup.notify(queue: .main) {
                continuation.resume(returning: labFindings)
            }
        }
    }
    
//    public func downloadAndSaveLabData (for patient: Patient, completionHanlder: @escaping (_ labData: [AnalysisType]) -> Void) {
//        downloadLabIDs(for: patient) { ids in
//            guard let ids = ids else {
//        return
//            }
//            downloadLabData(with: ids) { analyses in
//
//                print(analyses[0].name)
//                FetchingManager.shared.saveLabData(forPatient: patient, with: analyses)
//
//                completionHanlder(analyses)
//            }
//        }
//    }
    
    
    
    public func downloadAll () async -> Double? {
        
        var fetchedPatients : [Patient]?
        var double: Double?
        
        FetchingManager.shared.fetchPatientsFromCoreData { patients in
           fetchedPatients = patients
        }
        
        if let fetchedPatients = fetchedPatients {
            for patient in fetchedPatients {
                if let ids = await downloadLabIDs(for: patient) {
                    if let analyses = await downloadLabData(with: ids) {
                        double = Double(fetchedPatients.count) / Double(analyses.count)
                        print(analyses)
                        print(double)
                    }
                }
            }
        }

        
        return double
    }
    
   
    
}


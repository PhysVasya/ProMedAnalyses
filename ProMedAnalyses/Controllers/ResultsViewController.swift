//
//  TableForData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 14.12.2021.
//

import UIKit
import SwiftSoup

protocol TableForDataDelegate {
    func viewDidScroll(to position: CGFloat)
}

class ResultsViewController: UIViewController, TableForDataDelegate {
    
    var headerForSection = [String]()
    var collectionViewHeaderItems = [String]()
    var analysis = [Analysis]()

    
    let maximumHeight : CGFloat = 250
    let minimumHeight : CGFloat = 0
    
    var tableView = UITableView()
    var myLabel = UILabel()
    var headerHeight : NSLayoutConstraint?
    var headerTopAnchor : NSLayoutConstraint?
    
    //Loading Indicator to add visibility whether the process of loading is complete, initialized only
    let loadingIndicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        return indicator
    }()
    
    let alertwithError : UIAlertController = {
        let alert = UIAlertController(title: "Unfortunately, an error has occured.", message: "", preferredStyle: .alert)
        return alert
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.register(UINib(nibName: "ResultsTableCell", bundle: nil), forCellReuseIdentifier: K.resultsTableCell)
        tableView.delegate = self
        tableView.dataSource = self
        
       
    }
            
    func viewDidScroll (to position: CGFloat) {
        for cell in tableView.visibleCells as! [ReusableCellForResultsTableView] {
            cell.collectionView.contentOffset.x = position
        }
    }

}


// MARK: - Table view data source

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerForSection[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analysis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.resultsTableCell, for: indexPath) as! ReusableCellForResultsTableView
        cell.scrollDelegate = self
       
        if indexPath.row == 0 {
            cell.textStrings = collectionViewHeaderItems
            return cell
        } else {
            cell.textStrings.append(analysis[indexPath.row].element as! String)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
}

extension ResultsViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        if scrollOffset < 0 {
//            headerHeight?.constant += abs(scrollOffset)
        }
    }
    
    
}

//MARK: - Fetch Data Method Implementation

extension ResultsViewController {
    
    //Fetch PatientData from URL
    func fetchAnalysesData (for patientWithId: [String]) {
        //URL for HTTPRequest for loading patients' analyses
        let urlForRequest: URL? = {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "crimea.promedweb.ru"
            urlComponents.queryItems = [
                URLQueryItem(name: "c", value: "EvnXml"),
                URLQueryItem(name: "m", value: "doLoadData")]
            return urlComponents.url
        }()
        //1. URL created earlier unwrapped else return
        guard let url = urlForRequest else {
            return
        }
        
        //2. URLRequest, then added httpMethod and HeaderFields
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
            "Origin" : "https://crimea.promedweb.ru",
            "Referer" : "https://crimea.promedweb.ru/?c=promed",
            "Content-Length" : "54",
            "Cookie" : "io=RfBjHdPK47cqqxKAAiCx; JSESSIONID=73241BF7A7E30974BD403C9D1D78F418; login=TischenkoZI; PHPSESSID=houoor2ctkcjsmn1mabc6r1en3"
        ]
        
        //3. Body of URLRequest
        let body = "XmlType_id=4&Evn_id=820910076978020&EvnXml_id=\(patientWithId)"
        let finalBody = body.data(using: .utf8)
        request.httpBody = finalBody
        
        //4. Created URLSessionConfiguration (not obligatory)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        //5. DataTask for session created and resumed.
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self?.alertwithError.message = error!.localizedDescription
                    self?.present(self!.alertwithError, animated: true, completion: nil)
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                        self?.alertwithError.dismiss(animated: true, completion: nil)
                    }
                }
                return
            }
            
            if data != nil {
                if let unwrappedData = data {
                    print("Success")
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(ResultsData.self, from: unwrappedData)
                        //                        print(decodedData.dataForAnalysis)
                        let tableWithResultsData = try SwiftSoup.parse(decodedData.dataForAnalysis)
                        let analysisResults = try tableWithResultsData.getElementById("resolution")
                        if let headerTagsArray = try analysisResults?.getElementsByTag("th") {
                            for headerTag in headerTagsArray {
                                try self?.collectionViewHeaderItems.append(headerTag.text())
                            }
                        }
                        if let tableResultItems = try analysisResults?.getElementsByTag("tbody") {
                            for resultItem in tableResultItems {
                                let tableRowTags = try resultItem.getElementsByTag("tr")
                                for trtag in tableRowTags {
                                    let elementForTableRow = try trtag.text()
                                    let analys = Analysis(element: elementForTableRow)
                                    self?.analysis.append(analys)
                                }
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self?.alertwithError.message = (error as NSError).localizedDescription
                            self?.present(self!.alertwithError, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        loadingIndicator.stopAnimating()
        task.resume()
    }
}

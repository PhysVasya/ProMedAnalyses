//
//  TableForData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 14.12.2021.
//

import UIKit
import SwiftSoup
import CoreData



class ResultsViewController: UIViewController {
    
    
         
    var analysesView = [AnalysisView]() {
        didSet {
            analysesView.sort(by: <)
            tableView.reloadData()
        }
    }
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.register(UINib(nibName: K.nibResultsTableCell, bundle: nil), forCellReuseIdentifier: K.resultsTableCell)
        return tableView
    }()
  
    let searchController = UISearchController(searchResultsController: nil)
    var filteredAnalyses = [AnalysisView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSearchController()
    }
    
    func setupSearchController () {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Искать..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .words
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterSearchContent (_ content: String) {
        let rows = analysesView.flatMap{$0.rows}
        }
    
    
    
    func presentError (_ error: Error?) {
        guard let er = error else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "К сожалению, произошла ошибка", message: er.localizedDescription, preferredStyle: .alert)
            self?.present(alertController, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    alertController.dismiss(animated: true) {
                        
                    }
                }
            }
        }
    }
    
    func configureResultsVC (with analyses : [Analysis]) {
        analyses.forEach {
            let lab = AnalysisView(rows: $0.rows, date: $0.dateForHeaderInSection)
            analysesView.append(lab)
        }
        tableView.reloadData()
    }

}


// MARK: - Table view data source

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return analysesView.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return analysesView[section].date
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = analysesView[section]
        
        return section.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.resultsTableCell, for: indexPath) as! ResultsReusableCellController
        let rowData = analysesView[indexPath.section].rows[indexPath.row]
    
        cell.configure(labName: rowData[0], labValue: rowData[2])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension ResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar.text
        
        
    }
}



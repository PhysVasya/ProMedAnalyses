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
    let filterVC = FilterController()
    var usedFilters = [String]()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "slider.vertical.3"), style: .plain, target: self, action: #selector(filter))

        view.addSubview(tableView)
        
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = filterButton
    }
    
    func configureResultsVC (with analyses : [Analysis]) {
        analyses.forEach {
            let lab = AnalysisView(rows: $0.rows, date: $0.dateForHeaderInSection)
            analysesView.append(lab)
        }
        tableView.reloadData()
    }
    
    @objc func filter () {
        
        let nav = UINavigationController(rootViewController: filterVC)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
        }
        filterVC.navigationItem.title = "Параметры фильтров"
        filterVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(chooseFilters))
        filterVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(clear))
        
        present(nav, animated: true, completion: nil)
        
    }
    
    @objc func chooseFilters () {
        
        filterVC.sendFilters = { [weak self] filters in
            self?.usedFilters = filters
        }
        filterVC.dismiss(animated: true) {
            print(self.usedFilters)
        }
    }
    
    @objc func clear () {
        filterVC.selectedIndexPaths.removeAll()
        filterVC.selectedFilters.removeAll()
        filterVC.tableForProps.reloadData()
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





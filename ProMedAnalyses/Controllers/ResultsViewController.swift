//
//  TableForData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 14.12.2021.
//

import UIKit
import SwiftSoup
import CoreData

protocol ResultsViewControllerDelegate {
    func viewDidScroll(to position: CGFloat)
}

class ResultsViewController: UIViewController, ResultsViewControllerDelegate {
        
    var analysesView = [AnalysisView]()
    var tableView = UITableView() 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
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
        return analysesView[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.resultsTableCell, for: indexPath) as! ReusableCellForResultsTableView
        cell.scrollDelegate = self
        cell.textStrings = analysesView[indexPath.section].rows[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension ResultsViewController : UIScrollViewDelegate {
    
}



//
//  TableForData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 14.12.2021.
//

import UIKit

protocol TableForDataDelegate {
    func viewDidScroll(to position: CGFloat)
}

class ResultsViewController: UIViewController, TableForDataDelegate {
    
    var infoForRow = [String]()
    var headerForSection = [String]()
    var headerForCollectionView = [String]()
    
    let maximumHeight : CGFloat = 250
    let minimumHeight : CGFloat = 0
    
    var tableView = UITableView()
    var myLabel = UILabel()
    var headerHeight : NSLayoutConstraint?
    var headerTopAnchor : NSLayoutConstraint?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let header = HeaderView(dataForTable: headerForCollectionView)
        view.addSubview(tableView)
        view.addSubview(header)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.register(UINib(nibName: "ResultsTableCell", bundle: nil), forCellReuseIdentifier: K.resultsTableCell)
        tableView.delegate = self
        tableView.dataSource = self
        
        header.translatesAutoresizingMaskIntoConstraints = false
        header.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        headerHeight = header.heightAnchor.constraint(equalToConstant: 50)
        headerHeight?.isActive = true
        header.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerTopAnchor = header.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 140)
        headerTopAnchor?.isActive = true
        header.backgroundColor = .blue
        view.bringSubviewToFront(header)
            
       
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
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.resultsTableCell, for: indexPath) as! ReusableCellForResultsTableView
        cell.scrollDelegate = self
       
        
        if indexPath.row == 0 {
            cell.textStrings = headerForCollectionView
            return cell
        } else {
            cell.textStrings = infoForRow
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


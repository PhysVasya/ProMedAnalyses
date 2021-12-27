//
//  HeaderView.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 26.12.2021.
//

import UIKit

class HeaderView: UIView {
    
    required init (dataForTable: [String]) {
        self.strings = dataForTable
        super.init(frame: .zero)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let headerSubView = UITableView()
    var strings = [String]()
    
    override func layoutSubviews() {
        headerSubView.register(UINib(nibName: "ResultsTableCell", bundle: nil), forCellReuseIdentifier: K.resultsTableCell)
        headerSubView.delegate = self
        headerSubView.dataSource = self
        headerSubView.frame = self.bounds
        self.addSubview(headerSubView)
        
    }
    
}


extension HeaderView:  UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.resultsTableCell, for: indexPath) as! ReusableCellForResultsTableView
        cell.backgroundColor = .orange
        cell.textStrings = strings
        return cell
    }
}

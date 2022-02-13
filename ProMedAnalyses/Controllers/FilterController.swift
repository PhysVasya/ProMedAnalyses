//
//  FilterController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 09.02.2022.
//

import Foundation
import UIKit

class FilterController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let tableForProps = UITableView()
    let filters = ["Дата", "Тип услуги", "Только патологические"]
    var selectedFilters = [String]()
    var selectedIndexPaths = Set<IndexPath>()
    public var sendFilters : (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "Параметры фильтров"
        tableForProps.register(TableForPropsCell.self, forCellReuseIdentifier: "tableProps")
        tableForProps.frame = view.bounds
        view.addSubview(tableForProps)
        tableForProps.delegate = self
        tableForProps.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sendFilters?(selectedFilters)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "tableProps")
        var config = cell.defaultContentConfiguration()
        config.text = filters[indexPath.row]
        cell.contentConfiguration = config

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.remove(indexPath)
            selectedFilters.removeAll{$0 == filters[indexPath.row]}
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            selectedIndexPaths.insert(indexPath)
            selectedFilters.append(filters[indexPath.row])
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    

    
}

class TableForPropsCell: UITableViewCell {
    let identifier = "tableProps"
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

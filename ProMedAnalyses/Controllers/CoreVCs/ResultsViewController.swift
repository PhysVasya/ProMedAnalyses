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
    
    static let identifier = "resultsTableCell"
    
    var reassembledAnalyses = [AnalysisViewModel]() {
        didSet {
            if reassembledAnalyses.isEmpty {
                let alert = UIAlertController(title: "Ошибка", message: "Анализов с примененными фильтрами нет", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
                    alert.dismiss(animated: true) {
                        self?.filterVC.selectedDates = []
                        self?.filterVC.selectedFilter = nil
                        self?.filter()
                    }
                }
                alert.addAction(action)
                navigationController?.present(alert, animated: true, completion: nil)
            } else {
                fetchedAnalysesDates = reassembledAnalyses.compactMap{$0.date.components(separatedBy: CharacterSet.decimalDigits.inverted).filter{$0 != ""}.joined(separator: ".")}
                
                reassembledAnalyses.sort(by: <)
                tableView.reloadData()
            }
        }
    }
    var fetchedAnalysesDates : [String]?
    
    var reassembledAnalysesCopy = [AnalysisViewModel]() {
        didSet {
            reassembledAnalysesCopy.sort(by: <)
            tableView.reloadData()
        }
    }
    let tableView : UITableView = {
        let tableView = UITableView()
        tableView.register(UINib(nibName: "ResultsReusableCell", bundle: nil), forCellReuseIdentifier: ResultsCellViewController.identifier)
        return tableView
    }()
    let filterVC = FilterViewController()
    var references: [ReferenceForAnalysis]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Результаты анализов"
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), style: .plain, target: self, action: #selector(filter))
        let createPDFButton = UIBarButtonItem(image: UIImage(systemName: "doc.badge.plus"), style: .plain, target: self, action: #selector(createPDF))
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.setRightBarButtonItems([filterButton, createPDFButton], animated: true)
        getReferences()
        reassembledAnalysesCopy = reassembledAnalyses
        
    }
    
    func configureResultsVC (with analyses : [AnalysisType]) {
        analyses.forEach {
            let lab = AnalysisViewModel(rows: $0.analysis.data, date: $0.analysis.date)
            reassembledAnalyses.append(lab)
        }
        tableView.reloadData()
    }
    
    @objc func createPDF () {
        createPDFFromTableView()
        let pdfView = PDFViewController()
        let navController = UINavigationController(rootViewController: pdfView)
        navigationController?.present(navController, animated: true, completion: nil)
    }
    
    @objc func filter () {
        let nav = UINavigationController(rootViewController: filterVC)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
        }
        filterVC.configure(with: fetchedAnalysesDates?.uniqued())
        filterVC.sendFilters = { [weak self] passedFilter in
            guard let self = self else {
                return
            }
            
            guard let passedFilter = passedFilter else {
                self.reassembledAnalyses = self.reassembledAnalysesCopy
                return
            }

            if let dateFilter = passedFilter.dateFilter {
                if dateFilter != [] {
                    var analysesFilteredByDate: [AnalysisViewModel] = []
                    
                    var date = "" {
                        didSet {
                            let filteredAnalysisByDate : [AnalysisViewModel] = self.reassembledAnalysesCopy.compactMap({ eachAnalysis in
                                let formatter = DateFormatter()
                                let analysisDates = eachAnalysis.date.components(separatedBy: CharacterSet.decimalDigits.inverted).filter {$0 != ""}.joined(separator: ".")
                                formatter.dateFormat = "dd.MM.yyyy"
                                guard let formattedAnalysisDates = formatter.date(from: analysisDates) else {
                                    return nil
                                }
                                
                                let filterDate = date.components(separatedBy: CharacterSet.decimalDigits.inverted).filter{$0 != ""}.joined(separator: ".")
                                guard let formattedFilterDates = formatter.date(from: filterDate) else {
                                    return nil
                                }
                                return formattedFilterDates >= formattedAnalysisDates ? eachAnalysis : nil
                            })
                            analysesFilteredByDate.append(contentsOf: filteredAnalysisByDate)
                        }
                    }
                    dateFilter.forEach { receivedDate in
                        date = receivedDate
                    }
                    self.reassembledAnalyses = analysesFilteredByDate
                }
            }
            
            if let typeFilter = passedFilter.typeFilter {
                if typeFilter != "" {
                    self.reassembledAnalyses = self.reassembledAnalyses.compactMap({ eachAnalysis in
                        var filteredAnalyses: AnalysisViewModel?
                        
                        eachAnalysis.rows.forEach { el in
                            if el[0].lowercased().contains(typeFilter.lowercased()) {
                                filteredAnalyses = eachAnalysis
                            }
                        }
                        return filteredAnalyses
                    })
                } else {
                    self.reassembledAnalyses = self.reassembledAnalysesCopy
                }
            }
            
            if let pathological = passedFilter.pathologicalFilter {

                self.reassembledAnalyses = self.reassembledAnalyses.compactMap({ eachAnalysis in
                    var filteredAnalysis: AnalysisViewModel?
                    eachAnalysis.rows.forEach { el in
                        if el[2].contains("▲") || el[2].contains(pathological) {
                            let flt = AnalysisViewModel(rows: [el], date: eachAnalysis.date)
                            filteredAnalysis = flt
                        }
                    }
                    return filteredAnalysis
                })
            }
                        
        }
        present(nav, animated: true, completion: nil)
    }
    
    
    @objc func clear () {
        filterVC.selectedIndexPaths.removeAll()
        filterVC.selectedFilter = nil
        filterVC.tableForProps.reloadData()
    }
    
    func getReferences () {
        guard let path = Bundle.main.path(forResource: "Database", ofType: "json") else {
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let responseData = try decoder.decode([ReferenceForAnalysis].self, from: data)
            references = responseData
        } catch {
            print(error)
        }
        
    }
    
    func createPDFFromTableView () {
        let priorToBounds = tableView.bounds
        let fittedSize = tableView.sizeThatFits(CGSize(width: priorToBounds.size.width, height: tableView.contentSize.height))
        tableView.bounds = CGRect(x: 0, y: 0, width: fittedSize.width, height: fittedSize.height)
        
        let pdfPageBounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: view.frame.height)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)
        var pageOriginY = 0.0
        while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()?.saveGState()
            UIGraphicsGetCurrentContext()?.translateBy(x: 0, y: -pageOriginY)
            tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()?.restoreGState()
            pageOriginY += pdfPageBounds.size.height
        }
        UIGraphicsEndPDFContext()
        tableView.bounds = priorToBounds
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        docURL = docURL.appendingPathComponent("myDocument.pdf")
        pdfData.write(to: docURL, atomically: true)
    }
}


// MARK: - Table view data source

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reassembledAnalyses.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return reassembledAnalyses[section].date
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = reassembledAnalyses[section]
        
        return section.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ResultsViewController.identifier, for: indexPath) as! ResultsCellViewController
        let rowData = reassembledAnalyses[indexPath.section].rows[indexPath.row]
        var ref: ReferenceForAnalysis?
        if let refs = references {
            for item in refs {
                if rowData[0].lowercased().contains(item.name.lowercased()) {
                    ref = item
                }
            }
        }
        
        cell.configure(labName: rowData[0], labValue: rowData[2], labReference: ref)
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard let dates = fetchedAnalysesDates?.uniqued() else {
            return nil
        }
        return dates.compactMap{$0.prefix(_:2)}.map(String.init)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let dates = fetchedAnalysesDates else {
            return 0
        }
        
        guard let firstIndexOfSection = dates.compactMap({$0.prefix(_:2)}).map(String.init).firstIndex(of: title) else {
            return 0
        }
        
        return firstIndexOfSection
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ResultsCellViewController
        return UIContextMenuConfiguration(identifier: nil) {
            HapticsManager.shared.vibrate(for: .success)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let previewVC = storyboard.instantiateViewController(withIdentifier: PreviewViewController.identifier) as? PreviewViewController {
                previewVC.configurePreview(resultValue: ResultLabelPreview(value: selectedCell.analysisValue.text, labelColor: selectedCell.analysisValue.backgroundColor), normalValue: selectedCell.threshold.text, valueDescription: selectedCell.referenceDescription)
                return previewVC
            } else {
                return nil
            }
            
        } actionProvider: { suggestedActions in
            return UIMenu()
        }
    }
}


extension Sequence where Element: Hashable {
    
    func uniqued () -> [Element] {
        var set = Set<Element>()
        return filter {set.insert($0).inserted}
    }
    
}




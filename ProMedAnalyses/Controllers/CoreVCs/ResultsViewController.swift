//
//  TableForData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 14.12.2021.
//

import UIKit
import SwiftUI

class ResultsViewController: UIViewController {
    
    static let identifier = "resultsTableCell"
    public var patient: Patient?
    private var isConnected : Bool {
        return UserDefaults.standard.bool(forKey: "isConnected")
    }
    
    var reassembledAnalyses = [AnalysisViewModel]() {
        didSet {
            if reassembledAnalyses.isEmpty {
                let alert = UIAlertController(title: "Ошибка", message: "Анализов с примененными фильтрами нет", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
                    alert.dismiss(animated: true) {
                        self?.filterVC.selectedDate = nil
                        self?.filterVC.selectedFilter = nil
                        self?.presentFilterVC()
                    }
                }
                alert.addAction(action)
                navigationController?.present(alert, animated: true, completion: nil)
            } else {
                reassembledAnalyses.sort(by: {$0.date < $1.date})
            }
        }
    }
    var fetchedAnalysesDates : [String]? {
        return reassembledAnalyses.compactMap({$0.date}).sorted(by: {$0 < $1})
    }
    
    var reassembledAnalysesCopy = [AnalysisViewModel]()
    
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
        
        dataIsLoading(with: "Пожалуйста, подождите") { [weak self] indicator in
            self?.manageLoadingLabData(visually: indicator)
        }
        
        filterVC.sendFilters = { [weak self] passedFilter in

            
            guard let passedFilter = passedFilter else {
                self?.reassembledAnalyses = self!.reassembledAnalysesCopy
                self?.tableView.reloadData()
                return
            }
            
            if let dateFilter = passedFilter.dateFilter {
                self?.reassembledAnalyses = self!.reassembledAnalyses.compactMap({$0.date < dateFilter ? $0 : nil})
                self?.tableView.reloadData()
            }
            if let typeFilter = passedFilter.typeFilter {
                if typeFilter != "" {
                    self?.reassembledAnalyses = self!.reassembledAnalyses.compactMap({$0.name.lowercased().contains(typeFilter.lowercased()) ? $0 : nil})
                    self?.tableView.reloadData()
                }
            }
            
            if let pathologicalFilter = passedFilter.pathologicalFilter {
                self?.reassembledAnalyses = self!.reassembledAnalyses.compactMap({ eachAnalysis in
                    var filteredAnalysis: AnalysisViewModel?
                    eachAnalysis.analysis.forEach { el in
                        if el.value.contains("▲") || el.value.contains(pathologicalFilter) {
                            var pathologicalAnalyses = [Analysis]()
                            pathologicalAnalyses.append(Analysis(name: el.name, value: el.value))
                            let flt = AnalysisViewModel(name: eachAnalysis.name, date: eachAnalysis.date, analysis: pathologicalAnalyses)
                            filteredAnalysis = flt
                        }
                    }
                    return filteredAnalysis
                })
                self?.tableView.reloadData()
            }
            
        }
        
        getReferences()
        setupTableView()
        setupNavBarRightItems()
    }
    
    private func setupTableView () {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavBarRightItems () {
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .plain, target: self, action: #selector(presentFilterVC))
        let createPDFButton = UIBarButtonItem(image: UIImage(systemName: "doc.badge.plus"), style: .plain, target: self, action: #selector(createPDF))
        navigationItem.setRightBarButtonItems([filterButton, createPDFButton], animated: false)
    }
    
    private func manageLoadingLabData (visually: UIActivityIndicatorView) {
        if isConnected == true, let patient = patient {
            APICallManager.shared.downloadAndSaveLabData(for: patient) {
                FetchingManager.shared.fetchLabDataFromCoreData(for: patient) { labData in
                    if labData.count < 1 {
                        self.showErrorToTheUser(with: "К сожалению, данных для отображения нет", completionHanlderOnFailure: {
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                    } else {
                        self.reassembledAnalyses = labData
                        self.reassembledAnalysesCopy = labData
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            visually.stopAnimating()
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    visually.stopAnimating()
                }
            }
        } else if isConnected == false, let patient = patient {
            FetchingManager.shared.fetchLabDataFromCoreData(for: patient) { labData in
                if labData.count < 1 {
                    self.showErrorToTheUser(with: "К сожалению, данных для отображения нет", completionHanlderOnFailure: {
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                } else {
                    self.reassembledAnalyses = labData
                    self.reassembledAnalysesCopy = self.reassembledAnalyses
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        visually.stopAnimating()
                    }
                }
            }
        }
    }
    
    @objc func createPDF () {
        //        createPDFFromTableView()
        //        let pdfView = PDFViewController()
        //        let navController = UINavigationController(rootViewController: pdfView)
        //        navigationController?.present(navController, animated: true, completion: nil)
    }
    
    @objc func presentFilterVC () {
        
        if reassembledAnalyses.isEmpty {
            print("reassembeldanalyses is empty")
        } else {
            
            let nav = UINavigationController(rootViewController: filterVC)
            nav.sheetPresentationController?.detents = [.medium()]
            nav.sheetPresentationController?.selectedDetentIdentifier = .medium
            
            filterVC.configureFilterVC(send: fetchedAnalysesDates?.uniqued())
            
            present(nav, animated: true, completion: nil)
        }
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
        return "Дата реультата: \(reassembledAnalyses[section].date)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reassembledAnalyses[section].analysis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ResultsViewController.identifier, for: indexPath) as! ResultsCellViewController
        let rowData = reassembledAnalyses[indexPath.section].analysis[indexPath.row]
        var ref: ReferenceForAnalysis?
        references?.forEach({ reference in
            if rowData.name.lowercased().contains(reference.name.lowercased()) {
                ref = reference
            }
        })
        cell.configure(labName: rowData.name, labValue: String(rowData.value), labReference: ref)
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard let dates = fetchedAnalysesDates else {
            return nil
        }
        return dates.compactMap{$0.prefix(_:5)}.map(String.init).uniqued()
        
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        guard let firstIndexOfSection = fetchedAnalysesDates?.compactMap({$0.prefix(_:5)}).map(String.init).firstIndex(of: title) else {
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
            var valueBGColor : UIColor? {
                if selectedCell.analysisValue.backgroundColor == .systemBackground {
                    return .systemGray.withAlphaComponent(0.1)
                } else {
                    return selectedCell.analysisValue.backgroundColor
                }
            }
            let previewVC = UIHostingController(rootView: PreviewSwiftUIView(value: selectedCell.analysisValue.text!, normalValue: selectedCell.threshold.text!, description: selectedCell.referenceDescription!, color: valueBGColor!))
            return previewVC
            
            
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




//
//  ResultsViewController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 14.12.2021.
//

import UIKit
import SwiftUI

protocol ResultsViewControllerDelegate {
    func applyFilters(using: Filter)
}

class ResultsViewController: UIViewController, ResultsViewControllerDelegate {
    
    public var patient: Patient!
    private var references: [ReferenceForAnalysis]!
    private var reassembledAnalyses = [AnalysisViewModel]() { didSet { reassembledAnalyses.sort(by: {$0.date < $1.date}) } }
    private var reassembledAnalysesCopy = [AnalysisViewModel]()
    private var fetchedAnalysesDates : [String] { reassembledAnalyses.compactMap({$0.date}).sorted(by: {$0 < $1}) }
    private var isConnected = UserDefaults.standard.bool(forKey: "isConnected")
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.register(ResultsCellViewController.self, forCellReuseIdentifier: ResultsCellViewController.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBarRightItems()
        setupTableView()
        showLoadingData(label: "Пожалуйста, подождите") { [weak self] indicator in
            self?.manageLoadingLabData(showing: indicator)
        }
        getReferences()
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
    
    private func manageLoadingLabData (showing: UIActivityIndicatorView) {
        if isConnected == true {
            APICallManager.shared.downloadAndSaveLabData(for: patient) { [weak self] labData in
                self?.manageEmptyLabResults(labData: labData)
                showing.stopAnimating()
            }
        } else if isConnected == false {
            FetchingManager.shared.fetchLabDataFromCoreData(for: patient) { [weak self] labData in
                self?.manageEmptyLabResults(labData: labData)
                showing.stopAnimating()
            }
        }
    }
    
    private func manageEmptyLabResults (labData: [AnalysisViewModel]) {
        if labData.isEmpty {
            showErrorToTheUser(with: "К сожалению, данных для отображения нет", completionHanlderOnFailure: { [weak self] in
                 self?.navigationController?.popToRootViewController(animated: true)
            })
        } else {
            reassembledAnalyses = labData
            reassembledAnalysesCopy = self.reassembledAnalyses
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
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
        let filterVC = FilterViewController()
        let filterInNavVC = UINavigationController(rootViewController: filterVC)
        filterInNavVC.sheetPresentationController?.detents = [.medium()]
        filterInNavVC.sheetPresentationController?.selectedDetentIdentifier = .medium
        filterVC.delegate = self
        filterVC.availiableDates = fetchedAnalysesDates.uniqued()
        present(filterInNavVC, animated: true, completion: nil)
        
    }
    
    func applyFilters(using: Filter) {
        if using.dateFilter != nil {
            reassembledAnalyses = reassembledAnalysesCopy.compactMap { $0.date == using.dateFilter ? $0 : nil }
        }
        if using.typeFilter != nil && using.typeFilter != "" {
            reassembledAnalyses = reassembledAnalyses.compactMap { $0.name.lowercased().contains(using.typeFilter!.lowercased()) ? $0 : nil}
        }
        if using.pathologicalFilter != nil {
            reassembledAnalyses = reassembledAnalyses.compactMap({ model in
                var filtered = [Analysis]()
                model.analysis.forEach { an in
                    if an.value.contains("▲") || an.value.contains("▼") {
                        let analysis = Analysis(name: an.name, value: an.value)
                        filtered.append(analysis)
                    }
                }
                return AnalysisViewModel(name: model.name, date: model.date, analysis: filtered)
            })
        }
        
        if using.typeFilter == nil && using.dateFilter == nil && using.pathologicalFilter == nil {
            reassembledAnalyses = reassembledAnalysesCopy
        }
        tableView.reloadData()
        
    }
    
    
    func getReferences () {
        guard let path = Bundle.main.path(forResource: "Database", ofType: "json") else {
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            references = try JSONDecoder().decode([ReferenceForAnalysis].self, from: data)
        } catch {
            print("Error getting References from local DB: \(error)")
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ResultsCellViewController.identifier, for: indexPath) as! ResultsCellViewController
        let rowData = reassembledAnalyses[indexPath.section].analysis[indexPath.row]
        
        var ref: ReferenceForAnalysis?
        references.forEach({ reference in
            if rowData.name.lowercased().contains(reference.name.lowercased()) {
                ref = reference
            }
        })
        cell.configure(labName: rowData.name, labValue: rowData.value, labReference: (ref?.threshold) ?? "", refDescription: (ref?.description) ?? "")
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedAnalysesDates.compactMap{$0.prefix(_:5)}.map(String.init).uniqued()
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let firstIndexOfSection = fetchedAnalysesDates.compactMap({$0.prefix(_:5)}).map(String.init).firstIndex(of: title) else {
            return 0
        }
        return firstIndexOfSection
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ResultsCellViewController
        return UIContextMenuConfiguration(identifier: nil) {
            HapticsManager.shared.vibrate(for: .success)
            var valueBGColor : UIColor? {
                if selectedCell.valueLabel.backgroundColor == .systemBackground {
                    return .systemGray.withAlphaComponent(0.1)
                } else {
                    return selectedCell.valueLabel.backgroundColor
                }
            }
            let previewVC = UIHostingController(rootView: PreviewSwiftUIView(value: selectedCell.valueLabel.text!, normalValue: selectedCell.referenceValue!, description: selectedCell.referenceDescription!, color: valueBGColor!))
            return previewVC
            
            
        } actionProvider: { suggestedActions in
            return UIMenu()
        }
    }
}







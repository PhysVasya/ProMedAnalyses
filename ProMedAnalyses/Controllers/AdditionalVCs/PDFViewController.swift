//
//  PDFViewController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 06.03.2022.
//

import Foundation
import UIKit
import PDFKit


class PDFViewController: UIViewController {
    
    let pdfView = PDFView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)
        let url = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let document = PDFDocument(url: url.appendingPathComponent("myDocument.pdf", isDirectory: true))
        pdfView.document = document
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissSelf))
    }
    
    @objc func dismissSelf () {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.frame = view.bounds
        
    }
    
}

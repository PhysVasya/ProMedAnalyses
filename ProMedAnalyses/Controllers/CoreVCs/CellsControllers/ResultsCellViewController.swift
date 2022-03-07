//
//  reusableCell.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 17.12.2021.
//

import UIKit
import SwiftSoup

class ResultsCellViewController: UITableViewCell {
     
     static let identifier = "resultsTableCell"
     
     @IBOutlet weak var analysisName: UILabel!
     @IBOutlet weak var analysisValue: UILabel!
     @IBOutlet weak var threshold: UILabel!
     
     var referenceDescription: String?
 
     override func awakeFromNib() {
          super.awakeFromNib()
       
     }
     
     func configure (labName: String, labValue: String, labReference: ReferenceForAnalysis?) {
          analysisName.text = labName
          analysisName.backgroundColor = .systemGray6
          if labValue.contains("▲") {
               analysisValue.backgroundColor = .systemRed.withAlphaComponent(0.5)
          } else if labValue.contains("▼") {
               analysisValue.backgroundColor = .systemBlue.withAlphaComponent(0.3)
          } else {
               analysisValue.backgroundColor = .systemBackground
          }
   
          analysisValue.text = "Результат: \(labValue)"
          if let safeLabReference = labReference {
               threshold.text = "Норма: \(safeLabReference.threshold)"
               referenceDescription = labReference?.description
          }

     }
      
}

//
//  reusableCell.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 17.12.2021.
//

import UIKit
import SwiftSoup

class ResultsReusableCellController: UITableViewCell {
     
     @IBOutlet var analysisName: UILabel!
     @IBOutlet var analysisValue: UILabel!
     @IBOutlet var threshold: UILabel!
 
     override func awakeFromNib() {
          super.awakeFromNib()
       
     }
     
     func configure (labName: String, labValue: String) {
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
          threshold.text = "Норма: \(getReference(for: labName))"

     }
     
     func getReference (for labName: String) -> String {
          if labName.contains("прока") {
               return Reference.procalcitonin.rawValue
          } else if labName.contains("(некон") {
               return Reference.bilirubinIndirect.rawValue
          } else if labName.contains("(кон") {
               return Reference.bilirubinDirect.rawValue
          } else if labName.contains("уровня глюкозы") {
               return Reference.glucose.rawValue
          } else if labName.contains("креатин") {
               return Reference.creatinine.rawValue
          } else if labName.contains("мочевин") {
               return Reference.urea.rawValue
          } else if labName.contains("общего белка") {
               return Reference.protein.rawValue
          } else if labName.contains("общего билиру") {
               return Reference.bilirubinTotal.rawValue
          } else if labName.contains("аланин-амино") {
               return Reference.alt.rawValue
          } else if labName.contains("аспартат-амино") {
               return Reference.ast.rawValue
          } else if labName.contains("реактивный") {
               return Reference.crp.rawValue
          } else if labName.contains("ферритин") {
               return Reference.ferritin.rawValue
          } else if labName.contains("Treponema") || labName.contains("virus") {
               return Reference.hepB.rawValue
          } else if labName.contains("RBC") {
               return Reference.rbc.rawValue
          } else if labName.contains("WBC") {
               return Reference.wbc.rawValue
          } else if labName.contains("HGB") {
               return Reference.hgb.rawValue
          } else if labName.contains("скорости") {
               return Reference.esr.rawValue
          } else if labName.contains("Лимфоциты") {
               return Reference.lymphocytes.rawValue
          } else if labName.contains("Моноциты") {
               return Reference.monocytes.rawValue
          } else if labName.contains("палочкояд") {
               return Reference.stabs.rawValue
          } else if labName.contains("сегментояд") {
               return Reference.segmented.rawValue
          } else if labName.contains("гематокри") {
               return Reference.ht.rawValue
          } else if labName.contains("PLT") {
               return Reference.trombocytes.rawValue
          } else if labName.contains("Эозиноф") {
               return Reference.eosinophiles.rawValue
          } else {
               return Reference.eosinophiles.rawValue
          }
     }
   
}

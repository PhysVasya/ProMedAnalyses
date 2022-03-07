//
//  AnalysisView.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 03.03.2022.
//

import Foundation


struct AnalysisViewModel : Comparable, Hashable {
    static func < (lhs: AnalysisViewModel, rhs: AnalysisViewModel) -> Bool {
        lhs.date < rhs.date
    }
    
    let rows : [[String]]
    let date : String
    
    init(rows: [[String]], date: String) {
        self.rows = rows
        self.date = date
    }
}

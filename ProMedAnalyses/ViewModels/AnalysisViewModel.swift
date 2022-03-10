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
    
    let data : [[String]]
    let date : String
    
    init(data: [[String]], date: String) {
        self.data = data
        self.date = date
    }
}

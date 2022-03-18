//
//  AnalysisViewModel.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 15.03.2022.
//

import Foundation

struct AnalysisViewModel: Comparable {
    
    static func < (lhs: AnalysisViewModel, rhs: AnalysisViewModel) -> Bool {
        lhs.name < rhs.name
    }
    
    
    let name: String
    let value: String
    
    public init (name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    
}

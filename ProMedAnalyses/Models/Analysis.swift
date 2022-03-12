//
//  Analysis.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 03.03.2022.
//

import Foundation

struct AnalysisType {
    let analysis: AnalysisViewModel
    let evnUslugaID: String
    let evnXMLID: String
}

struct FetchedLabIDs {
    let evnXMLID: String
    let evnUslugaID: String
}

extension AnalysisType {
    
    var formattedToViewModel: AnalysisViewModel {
        return self.analysis
    }
    
}

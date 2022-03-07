//
//  Analysis.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 03.03.2022.
//

import Foundation

struct Analysis {
    let data : [[String]]
    let date : String
}

struct AnalysisType {
    let analysis: Analysis
    let evnUslugaID: String
    let evnXMLID: String
}

//
//  Analysis.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 03.03.2022.
//

import Foundation

struct AnalysisType {
    let analysis: AnalysisDataModel
    let evnUslugaID: String
    let evnXMLID: String
    let name: String
    let date: String
}

struct AnalysisDataModel {
  
    
    let data : [[String]]
    let date : String
    
    init(data: [[String]], date: String) {
        self.data = data
        self.date = date
    }
}

extension AnalysisType {
    
    var formattedToViewModel: AnalysisDataModel {
        return self.analysis
    }
    
}

struct FetchedLabIDs {
    let evnXMLID: String
    let evnUslugaID: String
    let uslugaName: String
    let evnUslugaDate: String
}



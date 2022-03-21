//
//  Analysis.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 03.03.2022.
//

import Foundation

struct AnalysisType {
    let analysis: AnalysisDataModel
    let evnUslugaID: Int
    let evnXMLID: Int
    let name: String
    let date: Date
}

struct AnalysisDataModel {
  
    
    let data : [[String]]
    let date : Date
    
    init(data: [[String]], date: Date) {
        self.data = data
        self.date = date
    }
}

struct AnalysisViewModel {
 
    let date: String
    let analysis: [Analysis]
    
    public init (date: String, analysis: [Analysis]) {
        
        self.date = date
        self.analysis = analysis
    }
    
    
}

struct Analysis {
    let name: String
    let value: String
}

extension AnalysisType {
    
    var formattedToViewModel: AnalysisDataModel {
        return self.analysis
    }
    
}

struct FetchedLabIDs {
    let evnXMLID: Int
    let evnUslugaID: Int
    let uslugaName: String
    let evnUslugaDate: Date
}



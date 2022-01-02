//
//  HTMLForResults.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 28.12.2021.
//

import Foundation

struct ResultsData : Decodable {
    
    var dataForAnalysis : String
    
    enum CodingKeys: String, CodingKey {
        case dataForAnalysis = "html"
    }
}


struct PatientsList : Decodable {
    var patientData : String
    var patientId : String
    
    
    enum CodingKeys: String, CodingKey {
        case patientData = "text"
        case patientId = "id"
    }
    
    
}


struct AnalysesList: Decodable {
    var success : Bool
    var map : [String]
    
   
}

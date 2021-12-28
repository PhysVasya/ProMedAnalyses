//
//  HTMLForResults.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 28.12.2021.
//

import Foundation

struct HTMLForResults : Codable {
    
    var html : String
    
    enum CodableKeys: String, CodingKey {
        
        case dataForAnalysis = "html"
    }
}

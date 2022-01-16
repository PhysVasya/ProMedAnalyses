//
//  PatientsTableData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 21.12.2021.
//

import Foundation

struct Ward: Equatable {
    var wardNumber: Int
    let wardType: WardType
    
    enum WardType {
        case oneMan, twoMan, threeMan, fourMan
    }
}

struct Patient: Equatable {
    
    let name : String
    let dateOfAdmission : String
    var ward : Ward
    let id : String
    let analysesIDs : [String]
    
    
    init(name: String, dateOfAdmission: String, ward: Ward = Ward(wardNumber: 0, wardType: .fourMan), id: String = "", labIDs: [String]) {
        self.name = name
        self.dateOfAdmission = dateOfAdmission
        self.ward = ward
        self.id = id
        self.analysesIDs = labIDs
    }
    
}

struct Analysis {
    var analysisData : String
    var id : String
}

struct TableRowForResultsVC {
    var tableRow : [String]
}

struct ListOfAnalysesIDs : Decodable {
    
    var htmlData : String?
    
    enum CodingKeys : String, CodingKey {
        case htmlData = "html"
    }
}

struct ListOfPatients : Decodable {
    
    var id : String?
    var name : String?
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case name = "html"
    }
}

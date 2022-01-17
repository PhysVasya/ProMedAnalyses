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
    let patientID : String
    let evnID : String
    
    
    init(name: String, dateOfAdmission: String, ward: Ward = Ward(wardNumber: 0, wardType: .fourMan), patientID: String, evnID: String) {
        self.name = name
        self.dateOfAdmission = dateOfAdmission
        self.ward = ward
        self.patientID = patientID
        self.evnID = evnID
    }
    
}

struct LabData {
    var analysisData : String
    var id : String
}

struct TableRowForResultsVC {
    var tableRow : [String]
}

struct FetchedListOfLabIDs : Decodable {
    
    var htmlData : String?
    
    enum CodingKeys : String, CodingKey {
        case htmlData = "html"
    }
}

struct FetchedListOfPatients : Decodable {
    
    var patientID : String?
    var name : String?
    var evnID : String?
    
    enum CodingKeys : String, CodingKey {
        case patientID = "EvnPS_id"
        case name = "text"
        case evnID = "id"
    }
}

struct FetchedLabData : Decodable {
    
    var data : String?
    
    enum CodingKeys : String, CodingKey {
        case data = "html"
    }
    
}

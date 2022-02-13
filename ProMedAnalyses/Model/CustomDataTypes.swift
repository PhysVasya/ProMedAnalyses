//
//  PatientsTableData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 21.12.2021.
//

import Foundation

struct Ward: Equatable {
 
    public static func == (lhs: Ward, rhs: Ward) -> Bool {
        return lhs.wardType == rhs.wardType && lhs.wardNumber == rhs.wardNumber
    }
    
    var wardNumber: Int
    let wardType: WardType
    
    init(wardNumber: Int, wardType: WardType) {
        self.wardNumber = wardNumber
        self.wardType = wardType
    }
    
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
    let labIDs : [String]
    
    
    init(name: String, dateOfAdmission: String, ward: Ward = Ward(wardNumber: 0, wardType: .fourMan), patientID: String, evnID: String, labIDs: [String] = []) {
        self.name = name
        self.dateOfAdmission = dateOfAdmission
        self.ward = ward
        self.patientID = patientID
        self.evnID = evnID
        self.labIDs = labIDs
    }
    
}

struct Analysis {
    let rows : [[String]]
    let dateForHeaderInSection : String
    let headerForAnalysis : [String]
}

struct AnalysisView : Comparable {
    static func < (lhs: AnalysisView, rhs: AnalysisView) -> Bool {
        lhs.date < rhs.date 
    }
    
    let rows : [[String]]
    let date : String
    var isExpanded : Bool 
    
    init(rows: [[String]], date: String, isExpanded: Bool = false) {
        self.rows = rows
        self.date = date
        self.isExpanded = isExpanded
    }
}


struct FetchedListOfLabIDs : Decodable {
    let map : Map?
    
    enum CodingKeys : String, CodingKey {
        case map
    }
}

struct Map : Decodable {
    let evnPS : EvnPS
    
    enum CodingKeys: String, CodingKey {
        case evnPS = "EvnPS"
    }
}

struct EvnPS : Decodable {
    let item : [EvnPSItem]
    
    enum CodingKeys: String, CodingKey {
        case item
    }
}

struct EvnPSItem : Decodable {
    let evnPSID: String
    let children : Children
    
    enum CodingKeys : String, CodingKey {
        case evnPSID = "EvnPS_id"
        case children
    }
}

struct Children : Decodable {
    let evnSection : EvnSection
    
    enum CodingKeys: String, CodingKey {
        case evnSection = "EvnSection"
    }
}

struct EvnSection : Decodable {
    let item : [EvnSectionItem]
    
    enum CodingKeys : String, CodingKey {
        case item
    }
}

struct EvnSectionItem : Decodable {
    let children : EvnSectionItemChildren
    
    enum CodingKeys: String, CodingKey {
        case children
    }
}

struct EvnSectionItemChildren : Decodable {
    let evnUslugaStac : EvnDiagDirectPS
    
    enum CodingKeys : String, CodingKey {
        case evnUslugaStac = "EvnUslugaStac"
    }
}

struct EvnDiagDirectPS : Decodable {
    let item : [EvnDiagDirectPSItem]?
    
    enum CodingKeys : String, CodingKey {
        case item
    }
}

struct EvnDiagDirectPSItem : Decodable {
    let data : EvnDiagDirectPSItemData
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct EvnDiagDirectPSItemData : Decodable {
    let evnXMLID : String
    let evnUslugaID, evnUslugaPID, evnUslugaRID : String
    
    enum CodingKeys : String, CodingKey {
        case evnXMLID = "EvnXml_id"
        case evnUslugaID = "EvnUsluga_id"
        case evnUslugaPID = "EvnUsluga_pid"
        case evnUslugaRID = "EvnUsluga_rid"
    }
}

struct FetchedListOfPatients : Decodable {
    let patientID : String?
    let name : String?
    let evnID : String?
    
    enum CodingKeys : String, CodingKey {
        case patientID = "EvnPS_id"
        case name = "text"
        case evnID = "id"
    }
}

struct FetchedLabData : Decodable {
    
    let data : String?
    
    enum CodingKeys : String, CodingKey {
        case data = "html"
    }
    
}

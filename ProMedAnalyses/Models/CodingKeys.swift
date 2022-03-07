//
//  PatientsTableData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 21.12.2021.
//

import Foundation

struct ReferenceForAnalysis: Codable {
    let name: String
    let threshold: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case threshold = "Threshold"
        case description = "Description"
    }
}

struct FetchedListOfLabIDs : Codable {
    let map : Map?
    
    enum CodingKeys : String, CodingKey {
        case map
    }
}

struct Map : Codable {
    let evnPS : EvnPS
    
    enum CodingKeys: String, CodingKey {
        case evnPS = "EvnPS"
    }
}

struct EvnPS : Codable {
    let item : [EvnPSItem]
    
    enum CodingKeys: String, CodingKey {
        case item
    }
}

struct EvnPSItem : Codable {
    let evnPSID: String
    let children : Children
    
    enum CodingKeys : String, CodingKey {
        case evnPSID = "EvnPS_id"
        case children
    }
}

struct Children : Codable {
    let evnSection : EvnSection
    
    enum CodingKeys: String, CodingKey {
        case evnSection = "EvnSection"
    }
}

struct EvnSection : Codable {
    let item : [EvnSectionItem]
    
    enum CodingKeys : String, CodingKey {
        case item
    }
}

struct EvnSectionItem : Codable {
    let children : EvnSectionItemChildren
    
    enum CodingKeys: String, CodingKey {
        case children
    }
}

struct EvnSectionItemChildren : Codable {
    let evnUslugaStac : EvnDiagDirectPS
    
    enum CodingKeys : String, CodingKey {
        case evnUslugaStac = "EvnUslugaStac"
    }
}

struct EvnDiagDirectPS : Codable {
    let item : [EvnDiagDirectPSItem]?
    
    enum CodingKeys : String, CodingKey {
        case item
    }
}

struct EvnDiagDirectPSItem : Codable {
    let data : EvnDiagDirectPSItemData
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct EvnDiagDirectPSItemData : Codable {
    let evnXMLID : String
    let evnUslugaID, evnUslugaPID, evnUslugaRID : String
    
    enum CodingKeys : String, CodingKey {
        case evnXMLID = "EvnXml_id"
        case evnUslugaID = "EvnUsluga_id"
        case evnUslugaPID = "EvnUsluga_pid"
        case evnUslugaRID = "EvnUsluga_rid"
    }
}

struct FetchedListOfPatients : Codable {
    let patientID : String?
    let name : String?
    let evnID : String?
    
    enum CodingKeys : String, CodingKey {
        case patientID = "EvnPS_id"
        case name = "text"
        case evnID = "id"
    }
}

struct FetchedLabData : Codable {
    
    let data : String?
    
    enum CodingKeys : String, CodingKey {
        case data = "html"
    }
    
    
    
}

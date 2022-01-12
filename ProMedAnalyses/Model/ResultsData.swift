//
//  HTMLForResults.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 28.12.2021.
//

import Foundation
import CoreData

struct ResultsData : Decodable {
    
    var dataForAnalysis : String
    
    enum CodingKeys: String, CodingKey {
        case dataForAnalysis = "html"
    }
}


class PatientsList : NSManagedObject, Decodable {
        
    enum CodingKeys: String, CodingKey {
        case patientData = "text"
        case patientId = "id"
//        case evnId = "EvnPS_id"
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
             let context = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
        let entity = NSEntityDescription.entity(forEntityName: "PatientsList", in: context) else {
            throw DecodingConfigurationError.missingManagedObjectContext
        }
        
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.patientId = try container.decode(String.self, forKey: .patientId)
        self.patientData = try container.decode(String.self, forKey: .patientData)
    }
}


struct AnalysesList: Decodable {
    var success : Bool
    var html : String
    
   
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
    
}

enum DecodingConfigurationError: Error {
    case missingManagedObjectContext
}

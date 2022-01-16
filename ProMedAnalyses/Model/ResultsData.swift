//
//  HTMLForResults.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 28.12.2021.
//

import Foundation
import CoreData


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


class AnalysesList: NSManagedObject, Decodable {
    
    enum CodingKeys : String, CodingKey {
        case html = "html"
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyMOC = CodingUserInfoKey.managedObjectContext,
              let context = decoder.userInfo[codingUserInfoKeyMOC] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "AnalysesList", in: context) else {
                  throw DecodingConfigurationError.missingManagedObjectContext
              }
        
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.html = try container.decode(String.self, forKey: .html)
    }
   
}


class AnalysisListData : NSManagedObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case data = "html"
        case id = "id"

    }
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyMOC = CodingUserInfoKey.managedObjectContext,
              let context = decoder.userInfo[codingUserInfoKeyMOC] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "AnalysisListData", in: context) else {
                  throw DecodingConfigurationError.missingManagedObjectContext
              }
        self.init(entity: entity, insertInto: context)
        
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode(String.self, forKey: .data)
    }
    
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
    
}

enum DecodingConfigurationError: Error {
    case missingManagedObjectContext
}

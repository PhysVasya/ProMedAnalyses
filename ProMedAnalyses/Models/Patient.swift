//
//  Patient.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 03.03.2022.
//

import Foundation

struct Patient: Equatable {
    static func == (lhs: Patient, rhs: Patient) -> Bool {
        lhs.ward.wardNumber == rhs.ward.wardNumber
    }
    
    
    let name : String
    let dateOfAdmission : String
    var ward : Ward
    let patientID : String
    let analyses: [AnalysisType]?
    
    
    
    init(name: String, dateOfAdmission: String, ward: Ward = Ward(wardNumber: 0, wardType: .fourMan), patientID: String, analyses: [AnalysisType]? = nil) {
        self.name = name
        self.dateOfAdmission = dateOfAdmission
        self.ward = ward
        self.patientID = patientID
        self.analyses = analyses
    }
    
}

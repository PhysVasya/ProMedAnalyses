//
//  Patient.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 03.03.2022.
//

import Foundation

struct Patient: Equatable {
    
    let name : String
    let dateOfAdmission : String
    var ward : Ward
    let patientID : String
    
    
    
    init(name: String, dateOfAdmission: String, ward: Ward = Ward(wardNumber: 0, wardType: .fourMan), patientID: String) {
        self.name = name
        self.dateOfAdmission = dateOfAdmission
        self.ward = ward
        self.patientID = patientID
    }
    
}

//
//  PatientsTableData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 21.12.2021.
//

import Foundation

struct Patient {
    
    let name: String
    let dateOfBirth: String
    let ward : Ward
    
    struct Ward {
        let wardNumber: Int
    }
    
    init(name: String, dateOfBirth: String, ward: Int) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.ward = Ward(wardNumber: ward)
    }
    
}

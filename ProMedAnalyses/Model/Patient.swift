//
//  PatientsTableData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 21.12.2021.
//

import Foundation

struct Ward: Equatable {
    let wardNumber: Int
    let wardType: WardType
    
    enum WardType {
        case oneMan, twoMan, threeMan, fourMan
    }
}

struct Patient {
    
    let name : String
    let dateOfBirth : String
    let ward : Ward
    let id : Int
    
    
    init(name: String, dateOfBirth: String, ward: Ward = Ward(wardNumber: 0, wardType: .fourMan), id: Int = 0) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.ward = ward
        self.id = id
    }
    
}

struct Analysis {
    var element : Any
}

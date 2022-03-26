//
//  Ward.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 03.03.2022.
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

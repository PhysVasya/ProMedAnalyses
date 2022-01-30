//
//  Threshold.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 27.01.2022.
//

import Foundation

enum Reference: String {
    case procalcitonin = "< 0.1 нг/мл"
    case bilirubinTotal = "1.71 - 20.5 мкмоль/л"
    case bilirubinDirect = "< 5.1 мкмоль/л"
    case bilirubinIndirect = "3,4 - 12,0 мкмоль/л"
    case glucose = "3,3 - 6,0 ммоль/л"
    case creatinine = "61,9 - 114,9 мкмоль/л"
    case urea = "2,1 - 8,5 мкмоль/л"
    case protein = "64 - 83 г/л"
    case alt = "7 - 55 Ед/л"
    case ast = "8 - 33 Ед/л"
    case crp = "0 - 5 мг/л"
    case ferritin = "24 - 336 нг/мл"
    case dDimer = "100 - 250 нг/мл"
    
    case inr = "1,0 - 1,3"
    case pti = "90 - 105 %"
    case fibrinogenA = "2 - 4 г/л"
    
    case hepC, hepB, pallidum = "Отрицательный"
    
    case rbc = "3,92 - 5,13"
    case wbc = "4,0 - 11,0"
    case hgb = "121 - 172 г/л"
    case esr = "0 - 29 мм/ч"
    case lymphocytes = "20 - 40 %"
    case monocytes = "2 - 8 %"
    case stabs = "0 - 5 %"
    case segmented = "47 - 72 %"
    case ht = "35,5 - 48,6 %"
    case trombocytes = "150 - 400"
    case eosinophiles = "0 - 6 %"
    
    case urineLeuk = "15 - 40 в п/зр"
    case urineProt = "0 - 0,033 г/л"
    case pH = "1,010 - 1,030"
}

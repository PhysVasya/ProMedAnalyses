//
//  TableData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 21.12.2021.
//

import Foundation
import SwiftSoup

struct ResultsTableData {
    let htmlElement: Element
    var id: Int
    
    init(span: Element, id: Int) {
        htmlElement = span
        self.id = id
    }
}

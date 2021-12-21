//
//  CollectionViewCell.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 18.12.2021.
//

import UIKit
import SwiftSoup

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var visibleData: UILabel!
    
    public func configure (with textForAnalysis: String) {
        self.visibleData.text = textForAnalysis
    }
    
}


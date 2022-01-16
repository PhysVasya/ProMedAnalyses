//
//  CollectionViewCell.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 18.12.2021.
//

import UIKit
import SwiftSoup

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var textForCollectionViewCell: UILabel!
    
    public func configure (with textForAnalysis: String) {
        self.textForCollectionViewCell.text = textForAnalysis
        textForCollectionViewCell.numberOfLines = 0
        
    }
    
    
}


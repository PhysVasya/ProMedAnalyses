//
//  reusableCell.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 17.12.2021.
//

import UIKit
import SwiftSoup

class ReusableCellForResultsTableView: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    var textStrings = [String]()
    var headerForAnalysesTableItems = [String]()
    var scrollDelegate: ResultsViewControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self        
        collectionView.register(UINib(nibName: "CollectionCellView", bundle: nil), forCellWithReuseIdentifier: K.collectionViewCellForResultsData)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return textStrings.count 
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.collectionViewCellForResultsData, for: indexPath) as! MyCollectionViewCell
    
        cell.configure(with: textStrings[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.viewDidScroll(to: scrollView.contentOffset.x)
    }
}

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
     
     var textStrings = [String]() {
          didSet {
               collectionView.reloadData()
          }
     }
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
          cell.textForCollectionViewCell.layer.borderWidth = CGFloat(0.5)
          cell.textForCollectionViewCell.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.5)
          if indexPath.row == 0 {
                           cell.textForCollectionViewCell.backgroundColor = .lightGray.withAlphaComponent(0.25)
               cell.textForCollectionViewCell.font = UIFont.systemFont(ofSize: 11)
          } else {
               cell.textForCollectionViewCell.backgroundColor = .systemBackground

               cell.textForCollectionViewCell.font = UIFont.systemFont(ofSize: 13)
          }
          cell.configure(with: textStrings[indexPath.row])
          return cell
     }
     
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
          scrollDelegate?.viewDidScroll(to: scrollView.contentOffset.x)
     }
}

//
//  CustomCollectionViewLayout.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 19.12.2021.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewLayout {
    
    var itemAttributesDict =  Dictionary<IndexPath, UICollectionViewLayoutAttributes>()
    var dataSourceDidUpdate = true
    var contentSize = CGSize.zero
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func prepare() {
        if !dataSourceDidUpdate {
            let xOffset = collectionView!.contentOffset.x
            let yOffset = collectionView!.contentOffset.y
            
            if let sectionCount = collectionView?.numberOfSections, sectionCount > 0 {
                
                for section in 0...sectionCount-1 {
                    
                    if let rowCount = collectionView?.numberOfItems(inSection: section), rowCount > 0 {
                        
                        if section == 0 {
                            for item in 0...rowCount-1 {
                                let indexPath = IndexPath(item: item, section: section)
                                
                                if let attrs = itemAttributesDict[indexPath] {
                                    var frame = attrs.frame
                                    
                                    if item == 0 {
                                        frame.origin.x = xOffset
                                    }
                                    frame.origin.y = yOffset
                                    attrs.frame = frame
                                }
                            }
                        } else {
                            let indexPath = IndexPath(item: 0, section: section)
                            
                            if let attrs = itemAttributesDict[indexPath] {
                                var frame = attrs.frame
                                frame.origin.x = xOffset
                                attrs.frame = frame
                            }
                        }
                    }
                }
            }
            return
        }
        
        dataSourceDidUpdate = false
        
        if let sectionCount = collectionView?.numberOfSections, sectionCount > 0 {
            for section in 0...sectionCount-1 {
                if let rowCount = collectionView?.numberOfItems(inSection: section), rowCount > 0 {
                    for item in 0...rowCount-1 {
                        
                        let cellIndex = IndexPath(item: item, section: section)
                        let xPos = Double(item) * 120
                        let yPos = Double(section) * 50
                        
                        let cellAtributes = UICollectionViewLayoutAttributes(forCellWith: cellIndex)
                        cellAtributes.frame = CGRect(x: xPos, y: yPos, width: 120, height: 50)
                        
                        
                        if section == 0 && item == 0 {
                            cellAtributes.zIndex = 4
                        } else if section == 0 {
                            cellAtributes.zIndex = 3
                        } else if item == 0 {
                            cellAtributes.zIndex = 2
                        } else {
                            cellAtributes.zIndex = 1
                        }
                        itemAttributesDict[cellIndex] = cellAtributes
                    }
                }
            }
        }
        
        let contentWidth = Double(collectionView!.numberOfItems(inSection: 0)) * 120
        let contentHeight = Double(collectionView!.numberOfSections) * 50
        self.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for cellAtributes in itemAttributesDict.values {
            if rect.intersects(cellAtributes.frame) {
                attributes.append(cellAtributes)
            }
        }
        
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributesDict[indexPath]!
    }
    
   
}

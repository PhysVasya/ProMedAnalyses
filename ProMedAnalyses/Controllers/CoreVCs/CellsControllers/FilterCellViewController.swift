//
//  FilterTableCell.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 22.02.2022.
//

import UIKit

class FilterCellViewController: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var customView: UIView!
    
    static let identifier = "filterTableCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
    }
    
    
    func configure (with text: String, view: UIView? = nil) {
        label.text = text
        label.textColor = .label
        guard let v = view else {
            customView.isHidden = true
            return
        }

        customView.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        
        if let textView = v as? UITextField {
            NSLayoutConstraint.activate([
                textView.bottomAnchor.constraint(equalTo: customView.bottomAnchor, constant: -customView.frame.height / 6),
                textView.topAnchor.constraint(equalTo: customView.topAnchor, constant: customView.frame.height / 6),
                textView.trailingAnchor.constraint(equalTo: customView.trailingAnchor),
                textView.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: customView.frame.width / 6)
            ])
                   
        } else {
            NSLayoutConstraint.activate([
                v.bottomAnchor.constraint(equalTo: customView.bottomAnchor),
                v.topAnchor.constraint(equalTo: customView.topAnchor),
                v.trailingAnchor.constraint(equalTo: customView.trailingAnchor),
                v.leadingAnchor.constraint(equalTo: customView.leadingAnchor)
            ])
        }
 
        self.customView = v
    }
    
    
}

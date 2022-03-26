//
//  ResultsCell.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 24.03.2022.
//

import Foundation
import UIKit

class ResultsCellViewController: UITableViewCell {
    
    static let identifier = "ResultsTableCell"
    
    public var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    public var valueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    public var referenceValue: String?
    public var referenceDescription: String?
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        valueLabel.font = .systemFont(ofSize: 12, weight: .regular)
        valueLabel.textColor = .label
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        nameLabel.sizeToFit()
        valueLabel.sizeToFit()
       
        stackView.contentMode = .scaleToFill
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.axis = .horizontal
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        selectionStyle = .none
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configure (labName: String, labValue: String, labReference: String, refDescription: String) {
                
        self.nameLabel.attributedText = labName.formatToStylizedAttributed()
        self.nameLabel.backgroundColor = .systemGray6
        self.referenceValue = "Норма: \(labReference)"
        self.referenceDescription = refDescription
        
        if labValue.contains("▲") {
             valueLabel.backgroundColor = UIColor(named: "ColorOrange")
             valueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
             valueLabel.textColor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1.00)
        } else if labValue.contains("▼") {
             valueLabel.backgroundColor = UIColor(named: "ColorBlue")
        } else {
             valueLabel.backgroundColor = .systemBackground
        }
        
        valueLabel.attributedText = labValue.formatToStylizedAttributed(additionalTextBefore: "Результат: ")
        
    }

    
}

extension String {
    
    func formatToStylizedAttributed (additionalTextBefore: String? = nil) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 20
        paragraphStyle.headIndent = 20
        let nameLabelAttrs : [NSAttributedString.Key : Any] = [ .paragraphStyle : paragraphStyle ]
        return additionalTextBefore == nil ? NSAttributedString(string: self, attributes: nameLabelAttrs) : NSAttributedString(string: additionalTextBefore! + self, attributes: nameLabelAttrs)
    }
    
}

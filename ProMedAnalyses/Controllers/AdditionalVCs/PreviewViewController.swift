//
//  PreviewViewController.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 16.02.2022.
//

import Foundation
import UIKit


class PreviewViewController: UIViewController {
    
    static let identifier = "previewViewController"
    
    var resultValue: String?
    var resultLabelColor: UIColor?
    var normalValue: String?
    var valueDescription: String?
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var normalValueLabel: UILabel!
    @IBOutlet weak var valueDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPreferences()
    }
    
    func configurePreview (resultValue: ResultLabelPreview, normalValue: String?, valueDescription: String?) {
        self.resultValue = resultValue.value
        self.resultLabelColor = resultValue.labelColor
        self.normalValue = normalValue
        self.valueDescription = valueDescription
    }
    
    func setPreferences () {
        resultLabel.text = resultValue
        resultLabel.backgroundColor = resultLabelColor
        normalValueLabel.text = normalValue
        valueDescriptionLabel.text = valueDescription
        normalValueLabel.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        
    }
    
}

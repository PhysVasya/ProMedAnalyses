//
//  HapticsManager.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 06.03.2022.
//

import Foundation
import UIKit


class HapticsManager {
    
    static let shared = HapticsManager()
    
    private init () {}
    
    func vibrate(for feedBackType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(feedBackType)
    }
    
    func vibrateForSelection () {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
}

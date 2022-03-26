//
//  PatientsViewController1.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 23.03.2022.
//

import Foundation
import UIKit

class PatientsTabBarController: UITabBarController {
    
    private var selectedTabBarItemIndex : Int = 0
    private var imagesForTabs = [UIImage(systemName: "person.3.sequence"), UIImage(systemName: "person.crop.rectangle")]
    private var isConnected : Bool? {
        UserDefaults.standard.bool(forKey: "isConnected")
    }
    private var patients = [Patient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Общий список"
        tabBar.tintColor = UIColor(named: "ColorOrange")
        view.backgroundColor = .systemBackground
        tabBar.scrollEdgeAppearance = UITabBarAppearance()
        
        showLoadingData(label: "Пожалуйста, подождите") { [weak self] indicator in
            self?.manageFetchingPatients(visually: indicator)
            DispatchQueue.main.async {
                let vc1 = UINavigationController(rootViewController: PatientsViewController(patients: self?.patients))
                let vc2 = UINavigationController(rootViewController: PatientsByWardsViewController(patients: self?.patients))
                vc1.title = "Общий список"
                vc2.title = "Список по палатам"
                self?.setViewControllers([vc1, vc2], animated: false)
                
                guard let items = self?.tabBar.items else {
                    return
                }
                
                for each in 0..<items.count {
                    items[each].image = self?.imagesForTabs[each]
                }
            }
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == tabBar.items![0] {
            selectedTabBarItemIndex = 0
        } else {
            selectedTabBarItemIndex = 1
        }
//        print(selectedTabBarItemIndex)
    }
    
    private func manageFetchingPatients (visually: UIActivityIndicatorView) {
        if isConnected == true {
            APICallManager.shared.getPatientsAndEvnIds { [weak self] _ in
                FetchingManager.shared.fetchPatientsFromCoreData { patients in
                    self?.patients = patients
                }
                DispatchQueue.main.async {
                    visually.stopAnimating()
                }
            }
        } else {
            FetchingManager.shared.fetchPatientsFromCoreData { [weak self] patients in
                self?.patients = patients
            }
            
            DispatchQueue.main.async {
                visually.stopAnimating()
            }
        }
    }
    
}





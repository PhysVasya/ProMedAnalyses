//
//  AppDelegate.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 13.12.2021.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
    
//        let entity = NSEntityDescription.entity(forEntityName: "ManagedLabData", in: persistentContainer.viewContext)!
//
//
//        let ids = ["820910079944175", "820910079944284", "820910079944543", "820910079944653", "820910079944232", "820910079944116", "820910079944064", "820910079944606", "820910079944701"]
//        let analyses = [
//            [["Определение антител к бледной трепонеме (Treponema Pallidum) в нетрепонемных тестах (RPR, РМП) (качественное и полуколичественное исследование) в сыворотке крови", "", "отрицательный", "-", "-"]],
//            [["Молекулярно-биологическое исследование крови на вирус гепатита С (Hepatitis С virus)", "", "Отрицательный", "-", "-"]],
//            [["Определение концентрации Д-димера в крови", "нг/мл", "2,90мг", "0.0 - 250.0", "-"]],
//            [["RBC (эритроциты)", "10^12/л", "5,0", "3,9 - 5,0", "-"], ["UWBC (лейкоциты)", "", "6,6", "-", "-"], ["Гемоглобин (HGB)", "г/л", "161  ▲", "120 - 160", "-"], ["Исследование скорости оседания эритроцитов", "", "1", "-", "-"], ["Лимфоциты", "", "18", "-", "-"], ["Моноциты", "", "4", "-", "-"], ["Нейтрофилы палочкоядерные", "", "9", "-", "-"], ["Нейтрофилы сегментоядерные", "", "69", "-", "-"], ["Оценка гематокрита", "%", "46", "40 - 48", "-"], ["Тромбоциты (PLT)", "10^9/л", "221", "180,0 - 320,0", "-"], ["Эозинофилы %", "", "0", "-", "-"]],
//            [["Определение международного нормализованного отношения (МНО)", "", "1,5  ▲▲", "-", "1.0 - 1.3"], ["Протромбиновый индекс", "%", "88,5  ▼▼", "-", "90 - 105"], ["Фибриноген А", "г/л", "3,4", "-", "2 - 4"]],
//            [["Исследование уровня билирубина свободного (неконъюгированного) в крови", "мкмоль/л", "3,8", "-", "1.7 - 16.4"], ["Исследование уровня билирубина связанного (конъюгированного) в крови", "мкмоль/л", "2,5", "-", "0 - 4.3"], ["Исследование уровня глюкозы в крови", "", "6,3", "-", "-"], ["Исследование уровня креатинина в крови", "", "70,0", "-", "-"], ["Исследование уровня мочевины в крови", "", "2,9", "-", "-"], ["Исследование уровня общего белка в крови", "г/л", "78,2", "-", "64 - 83"], ["Исследование уровня общего билирубина в крови", "", "6,3", "-", "-"], ["Определение активности аланин-аминотрансферазы в крови", "Ед/л", "66,0  ▲", "0 - 31", "-"], ["Определение активности аспартат-аминотрансферазы в крови", "Ед/л", "15,0", "0 - 37", "-"], ["С-реактивный белок", "мг/л", "11,0  ▲▲", "-", "0 - 5"]],
//            [["Исследование уровня ферритина в крови", "нг/мл", "138  ▲", "0.000 - 125.000", "-"]],
//            [["Исследование уровня прокальцитонина в крови", "нг/мл", "0,17  ▲", "0.000 - 0.100", "-"]],
//            [["Молекулярно-биологическое исследование крови на вирус гепатита В (Hepatitis В virus)", "", "Отрицательный", "-", "-"]]
//]
//        let dates = ["Дата забора 21/01/2022", "Дата забора 21/01/2022", "Дата забора 21/01/2022", "Дата забора 21/01/2022", "Дата забора 21/01/2022", "Дата забора 21/01/2022", "Дата забора 22/01/2022", "Дата забора 23/01/2022", "Дата забора 23/01/2022"]
//
//        for index in 0..<ids.count {
//            let managedLabData = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext) as! ManagedLabData
//            managedLabData.labID = ids[index]
//            managedLabData.header = ["Название анализа", "Единицы измерения", "Результат", "Нормальный диапазон", "Критическиф диапазон"]
//            managedLabData.data = analyses[index]
//            managedLabData.date = dates[index]
//            managedLabData.xmlID = ""
//
//        }
////
//        let entity2 = NSEntityDescription.entity(forEntityName: "ManagedPatient", in: persistentContainer.viewContext)!
//        let managedPatient = NSManagedObject(entity: entity2, insertInto: persistentContainer.viewContext) as! ManagedPatient
//        managedPatient.labID = "820910079943729"
//        managedPatient.dateOfAdmission = "Поступил: 19.01.2022"
//        managedPatient.patientID = "820910079943544"
//        managedPatient.patientName = "Мандзюк Александр Ивановичfgg"
//        managedPatient.idsToFetchAnalyses = ["820910079944175", "820910079944284", "820910079944543", "820910079944653", "820910079944232", "820910079944116", "820910079944064", "820910079944606", "820910079944701"]
//
//        saveContext()

        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ProMedAnalyses")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


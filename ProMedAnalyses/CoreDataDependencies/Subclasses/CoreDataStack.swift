//
//  CoreDataStacks.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 01.02.2022.
//

import Foundation
import CoreData


class CoreDataStack {
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var container: NSPersistentContainer = {
        let cont = NSPersistentContainer(name: self.modelName)
        cont.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return cont
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return container.viewContext
    }()
    
    func saveContext () {
        
        guard managedContext.hasChanges else {
            return
        }
        do {
            try managedContext.save()

        } catch let error as NSError {
            print("Unresoled error \(error), \(error.userInfo) ")
        }
    }
    
    public func clearDatabase() {
        guard let url = container.persistentStoreDescriptions.first?.url else { return }
        
        let persistentStoreCoordinator = container.persistentStoreCoordinator

         do {
             try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
             try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
         } catch {
             print("Attempted to clear persistent store: " + error.localizedDescription)
         }
    }
    
}

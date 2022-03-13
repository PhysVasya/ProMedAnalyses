//
//  ManagingFetching.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 19.02.2022.
//

import Foundation
import CoreData


class FetchingManager {
    
    static let shared = FetchingManager()
    static let managedPatient = "ManagedPatient"
    static let managedLabData = "ManagedLabData"
    public var sharedPatient: ManagedPatient?
    
    private let context = CoreDataStack(modelName: "ProMedAnalyses").managedContext
    
    private init () { }
    
    enum FetchingError: String, Error {
        case unableToFetchPatientFromCoreData = "Unable to fetch patient from CoreData"
        case unableToFetchAnalysisDataFromCoreData = "Unable to fetch analysis data from CoreData"
        case thereIsNoSuchPatient = "There patient is already saved locally"
    }
    
    enum SavingError: String, Error {
        case unableToSavePatient = "Unable to save patient"
        case unableToProperlyDeletePatient = "Unable to properly delete patient"
        case unableToSaveAnalysis = "Unable to save analysis"
    }
    
    public func checkPatientAndSaveIfNeeded (patient: Patient, completionHanlder: ((Result<ManagedPatient?, Error>) -> Void)? = nil) {
        
        let patientFetch: NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        patientFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(ManagedPatient.patientID), patient.patientID)
        var checkingPatient : ManagedPatient?
        
        do {
            let results = try context.fetch(patientFetch)
            if results.count > 0 {
                checkingPatient = results.first
                completionHanlder?(.success(checkingPatient))
            } else {
                completionHanlder?(.failure(FetchingError.thereIsNoSuchPatient))
                savePatient(patient: patient)
                print(patient)
            }
            
        } catch let error as NSError {
            print("\(FetchingError.unableToFetchPatientFromCoreData.rawValue): \(error)")
        }
        
    }
    
    public func fetchPatientsFromCoreData (completionHandler: (_ : [Patient])->Void) {
        
        var fetchedPatients = [Patient]()
        let request : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        do {
            let fetchedPatientsFromCoreData = try self.context.fetch(request)
            for fetchedPatient in fetchedPatientsFromCoreData {
                let patient = Patient(name: fetchedPatient.patientName!, dateOfAdmission: fetchedPatient.dateOfAdmission!.getFormattedDate(), ward: Ward(wardNumber: Int(fetchedPatient.wardNumber), wardType: .fourMan), patientID: fetchedPatient.patientID!)
                fetchedPatients.append(patient)
                
            }
            completionHandler(fetchedPatients)
            
        } catch let error {
            print("\(FetchingError.unableToFetchPatientFromCoreData.rawValue): \(error)")
        }
        
    }
    
    
    
    public func fetchLabDataFromCoreData (for patient: Patient, completionHandler: @escaping (_ : [AnalysisViewModel]) -> Void) {
        
        let request : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ManagedPatient.patientID), patient.patientID)
        do {
            let fetchedPatient = try context.fetch(request)
            if let fetchedAnalyses = fetchedPatient.first?.analysis?.compactMap({$0}) as? [ManagedLabData] {
                completionHandler( fetchedAnalyses.map { AnalysisViewModel(data: $0.data!, date: $0.date!.getFormattedDate()) })
            }
        } catch let error {
            print("\(FetchingError.unableToFetchAnalysisDataFromCoreData.rawValue): \(error.localizedDescription)")
        }
    }
    
    public func fetchOnlyPatientsWithAnalyses (completion: ([Patient]) -> Void) {
        let request : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        do {
            let results = try context.fetch(request)
            let mappedPatients = results.compactMap { patient -> ManagedPatient? in
                let patientAnalysis = patient.analysis?.compactMap({$0}) as? [ManagedLabData]
                return patientAnalysis!.isEmpty ? nil : patient
            }
            
            let patients = mappedPatients.map { Patient(name: $0.patientName!, dateOfAdmission: ($0.dateOfAdmission?.getFormattedDate())!, patientID: $0.patientID!)}
            completion(patients)
        } catch let error {
            print(error)
        }
    }
    
    public func fetchPatientsWithHighCRP (completion: ([Patient]) -> Void) {
        let request: NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        do {
            let results = try context.fetch(request)
            var managedMatchedPatients = [ManagedPatient]()
            results.compactMap { patient -> ManagedPatient? in
                if let patientAnalysis = patient.analysis?.compactMap({$0}) as? [ManagedLabData] {
                    patientAnalysis.forEach { analysisType in
                        analysisType.data?.forEach({ analysis in
                            let matches = analysis[0].lowercased().contains("с-реа".lowercased()) && analysis[2].lowercased() > "5"
                            if matches {
                                managedMatchedPatients.append(patient)
                            }
                        })
                    }
                    return patientAnalysis.isEmpty ? nil : patient
                } else {
                    return nil
                }
                
            }
            completion(managedMatchedPatients.map({Patient(name: $0.patientName!, dateOfAdmission: ($0.dateOfAdmission?.getFormattedDate())!, patientID: $0.patientID!)}))
           
        } catch let error {
            print(error)
        }
        
    }
    
    
    public func changeWardAndSavePatient (patient: Patient, moveTo: Int) {
        
        let fetch: NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(ManagedPatient.patientID), patient.patientID)
        fetch.predicate = predicate
        
        do {
            let result = try context.fetch(fetch)
            if result.count > 0 {
                guard let existingPatient = result.first else {
                    return
                }
                existingPatient.wardNumber = Int16(moveTo)
               
                if context.hasChanges {
                    try context.save()
                }
            }
        } catch let error as NSError {
            print("Error moving and  saving patient \(error)")
        }
    }
    
    private func savePatient (patient: Patient) {
        
        let managedPatient = ManagedPatient()
        managedPatient.patientID = patient.patientID
        managedPatient.dateOfAdmission = patient.dateOfAdmission.getFormattedDateFromString()
        managedPatient.patientName = patient.name
        managedPatient.wardNumber = Int16(patient.ward.wardNumber)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("\(SavingError.unableToSavePatient) : \(error)")
            }
        }
        
    }
    
    func deletePatient (patient: Patient) {
        
        let patientToDelete = ManagedPatient(context: context)
        patientToDelete.patientID = patient.patientID
                    
        context.delete(patientToDelete)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print("\(SavingError.unableToProperlyDeletePatient.rawValue): \(error)")
            }
        }
    }
    
    func saveLabData (forPatient: Patient, with analysisType: [AnalysisType]) {
        
        let fetchPatient: NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        fetchPatient.predicate = NSPredicate(format: "%K == %@", #keyPath(ManagedPatient.patientName), forPatient.name)
        do {
            let results = try context.fetch(fetchPatient)
            if results.count > 0 {
                sharedPatient = results.first
            }
        } catch let error {
            print("Error fetching patient and saing labs \(error)")
        }
        
        analysisType.forEach { analysis in
            let managedLabData = ManagedLabData(context: context)
            managedLabData.evnXMLID = analysis.evnXMLID
            managedLabData.evnUslugaID = analysis.evnUslugaID
            
            let date = analysis.analysis.date.getDateFormatted()
            managedLabData.date = date.getFormattedDateFromString()
            managedLabData.data = analysis.analysis.data
            sharedPatient?.addToAnalysis(managedLabData)
            
            if context.hasChanges {
                do {
                    
                    try self.context.save()
                } catch let error {
                    print("\(SavingError.unableToSaveAnalysis.rawValue): \(error)")
                }
            }
        }
    }
}

extension String {
    
    func getDateFormatted() -> String {
        var date = self.lowercased().components(separatedBy: NSCharacterSet.letters).joined()
        date.removeFirst(4)
        date.removeLast(2)
        return date
    }
}


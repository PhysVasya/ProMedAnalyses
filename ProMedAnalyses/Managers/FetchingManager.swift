//
//  ManagingFetching.swift
//  ProMedAnalyses
//
//  Created by Vasiliy Andreyev on 19.02.2022.
//

import Foundation
import CoreData


struct FetchingManager {
    
    static var shared = FetchingManager()
    static let managedPatient = "ManagedPatient"
    static let managedLabData = "ManagedLabData"
        
    private let context = CoreDataStack(modelName: "ProMedAnalyses").managedContext
    
    private init () { }
    
    enum FetchingError: Error, LocalizedError {
        
        case unableToFetchPatientFromCoreData(Error)
        case unableToFetchAnalysisDataFromCoreData(Error)
        case thereIsNoSuchPatient
        case thereAreNoAlanysesInPatient(Error)
        
        var errorDescription: String? {
            switch self {
            case .unableToFetchPatientFromCoreData(let error):
                return "Unable to fetch patient from CoreData : \(error)"
            case .unableToFetchAnalysisDataFromCoreData(let error):
                return "Unable to fetch analysis data from CoreData : \(error)"
            case .thereIsNoSuchPatient:
                return "There patient is already saved locally"
            case .thereAreNoAlanysesInPatient(let error):
                return "There are no saved analysis in this patient: \(error)"
            }
        }
    }
    
    enum SavingError: Error, LocalizedError {
        
        case unableToSavePatient(Error)
        case unableToProperlyDeletePatient(Error)
        case unableToSaveAnalysis(Error)
        case unableToMovePatient(Error)
        case errorSavingLabData(Error)
        
        public var errorDescription: String? {
            switch self {
            case .unableToSavePatient(let error):
                return "Unable to save patient : \(error)"
            case .unableToProperlyDeletePatient(let error):
                return "Unable to properly delete patient : \(error)"
            case .unableToSaveAnalysis(let error):
                return "Unable to save analysis : \(error)"
            case .unableToMovePatient(let error):
                return "Unable to move and save patients correctly : \(error)"
            case .errorSavingLabData(let error):
                return "Error saving LabData : \(error)"
            }
        }
    }
    
    public func checkPatientAndSaveIfNeeded (patient: Patient, completionHanlder: ((Result<ManagedPatient?, Error>) -> Void)? = nil) {
        
        //Classic FIND or CREATE pattern
        
        let patientFetch: NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        let predicate = NSPredicate(format: "patientID == \(patient.patientID)")
        patientFetch.predicate = predicate
        var checkingPatient : ManagedPatient?
        
        do {
            let results = try context.fetch(patientFetch)
            if results.count > 0 {
                checkingPatient = results.first
                completionHanlder?(.success(checkingPatient))
            } else {
                completionHanlder?(.failure(FetchingError.thereIsNoSuchPatient))
                savePatient(patient: patient)
            }
            
        } catch let error as NSError {
            print(FetchingError.unableToFetchPatientFromCoreData(error).localizedDescription)
        }
    }
    
    public func fetchPatientsFromCoreData (completionHandler: (_ : [Patient])->Void) {
        
        var fetchedPatients = [Patient]()
        let request : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        do {
            let fetchedPatientsFromCoreData = try self.context.fetch(request)
            for fetchedPatient in fetchedPatientsFromCoreData {
                let patient = Patient(name: fetchedPatient.patientName!, dateOfAdmission: fetchedPatient.dateOfAdmission!.getFormattedDate(), ward: Ward(wardNumber: Int(fetchedPatient.wardNumber), wardType: .fourMan), patientID: Int(fetchedPatient.patientID), birthday: (fetchedPatient.birthday?.getFormattedDate())!, sex: fetchedPatient.sex!)
                fetchedPatients.append(patient)
            }
            completionHandler(fetchedPatients)
        } catch let error {
            print(FetchingError.unableToFetchPatientFromCoreData(error).localizedDescription)
        }
    }
    
    
    
    public func fetchLabDataFromCoreData (for patient: Patient, completionHandler: @escaping (_ : [AnalysisViewModel]) -> Void) {
        
        let patientsRequest : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        let patientsPredicate = NSPredicate(format: "patientID == \(patient.patientID)")
        patientsRequest.predicate = patientsPredicate
        do {
            let fetchedPatient = try context.fetch(patientsRequest)
            let fetchedLabData = fetchedPatient.first?.labsData?.compactMap({$0}) as? [ManagedLabData]
            var finalAnalysis = [AnalysisViewModel]()
            
            fetchedLabData?.forEach({ labData in
                if let fetchedAnalyses = labData.analyses?.compactMap({$0}) as? [ManagedAnalysis] {
                    let viewFormattedFetchedAnalyses = fetchedAnalyses.compactMap { managedAnalysis -> Analysis? in
                        if let name = managedAnalysis.name,
                           let value = managedAnalysis.value {
                            return Analysis(name: name, value: value) } else { return nil }
                    }
                    if let date = labData.date?.getFormattedDate(),
                       let name = labData.name {
                        finalAnalysis.append(AnalysisViewModel(name: name, date: date, analysis: viewFormattedFetchedAnalyses))
                    }
                }
            })
            completionHandler(finalAnalysis)
        } catch let error {
            print(FetchingError.unableToFetchAnalysisDataFromCoreData(error).localizedDescription)
        }
    }
    
    public func fetchOnlyPatientsWithAnalyses (completion: ([Patient]) -> Void) {
        
        let request : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            
            let mappedPatientsWithAnalyses = results.compactMap { patient -> ManagedPatient? in
                let mappedPatientAnalysis = patient.labsData?.compactMap({$0}) as? [ManagedLabData]
                return mappedPatientAnalysis!.isEmpty ? nil : patient
            }
            
            let patients = mappedPatientsWithAnalyses.map { Patient(name: $0.patientName!, dateOfAdmission: ($0.dateOfAdmission?.getFormattedDate())!, patientID: Int($0.patientID), birthday: ($0.birthday?.getFormattedDate())!, sex: $0.sex!)
            }
            completion(patients)
            
        } catch let error as NSError {
            print(FetchingError.thereAreNoAlanysesInPatient(error).localizedDescription)
        }
    }
    
    public func fetchPatientsWithHighCRP (completion: ([Patient]) -> Void) {
        let request: NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        
    }
    
    
    public func changeWardAndSavePatient (patient: Patient, moveTo: Int) {
        
        let fetch: NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "patientID == \(patient.patientID)")
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
            print(SavingError.unableToMovePatient(error).localizedDescription)
        }
    }
    
    private func savePatient (patient: Patient) {
        
        let managedPatient = ManagedPatient(context: context)
        managedPatient.patientID = Int64(patient.patientID)
        managedPatient.dateOfAdmission = patient.dateOfAdmission.getFormattedDateFromString()
        managedPatient.sex = patient.sex
        managedPatient.birthday = patient.birthday.getFormattedDateFromString()
        managedPatient.patientName = patient.name
        managedPatient.wardNumber = Int16(patient.ward.wardNumber)
        
        if self.context.hasChanges {
            do {
                try self.context.save()
            } catch let error as NSError {
                print(SavingError.unableToSavePatient(error).localizedDescription)
            }
        }
        
        
    }
    
    public func deletePatient (patient: Patient) {
        
        let patientToDelete = ManagedPatient(context: context)
        patientToDelete.patientID = Int64(patient.patientID)
        context.delete(patientToDelete)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(SavingError.unableToProperlyDeletePatient(error).localizedDescription)
            }
        }
    }
    
    public func saveLabData (forPatient: Patient, with analysisType: [AnalysisType]) {
        
        var sharedPatient: ManagedPatient?
        
        let fetchPatient: NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        fetchPatient.predicate = NSPredicate(format: "patientID == \(forPatient.patientID)")
        do {
            let results = try context.fetch(fetchPatient)
            if results.count > 0 {
                sharedPatient = results.first
            }
        } catch let error {
            print(SavingError.errorSavingLabData(error).localizedDescription)
        }
        
        analysisType.forEach { analysis in
            let managedLabDataFetch : NSFetchRequest<ManagedLabData> = ManagedLabData.fetchRequest()
            managedLabDataFetch.predicate = NSPredicate(format: "evnUslugaID == \(analysis.evnUslugaID)")
            
            do {
                let results1 = try context.fetch(managedLabDataFetch)
                if results1.count == 0 {
                    let managedLabData = ManagedLabData(context: context)
                    managedLabData.evnXMLID = Int64(exactly: analysis.evnXMLID)!
                    managedLabData.evnUslugaID = Int64(exactly: analysis.evnUslugaID)!
                    managedLabData.date = analysis.date
                    managedLabData.name = analysis.name
                    managedLabData.patient = sharedPatient
                    
                    let analysisNames = analysis.analysis.data.map { eachAnalysis in
                        return eachAnalysis[0]
                    }
                    let analysisValues = analysis.analysis.data.map { eachAnalysis in
                        return eachAnalysis[2]
                    }
                    
                    let nameValuePair = Dictionary(uniqueKeysWithValues: zip(analysisNames, analysisValues))
                    
                    for (name, value) in nameValuePair {
                        let managedAnalysis = ManagedAnalysis(context: context)
                        managedAnalysis.name = name
                        managedAnalysis.value = value
                        managedAnalysis.patient = sharedPatient
                        managedLabData.addToAnalyses(managedAnalysis)
                    }
                    
                    if context.hasChanges {
                        do {
                            try self.context.save()
                        } catch let error {
                            print(SavingError.unableToSaveAnalysis(error).localizedDescription)
                        }
                    }
                }
                
            } catch let error as NSError {
                print(SavingError.unableToSaveAnalysis(error).localizedDescription)
            }
        }
    }
}

extension String {
    
    var getPatientDateFormatted : String {
        var date = self.lowercased().components(separatedBy: .letters).joined()
        date.removeLast(1)
        date.removeFirst(2)
        return date
    }
    
    var getAnalysisDateFormatted : String {
        var date = self.lowercased().components(separatedBy: .letters).joined()
        date.removeLast(2)
        date.removeFirst(4)
        return date
    }
    
}


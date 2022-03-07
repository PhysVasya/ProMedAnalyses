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
        patientFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(ManagedPatient.patientName), patient.name)
        var checkingPatient : ManagedPatient?

        do {
            let results = try context.fetch(patientFetch)
            if results.count > 0 {
                checkingPatient = results.first
                completionHanlder?(.success(checkingPatient))
            } else {
                checkingPatient?.patientName = patient.name
                checkingPatient?.patientID = patient.patientID
                checkingPatient?.dateOfAdmission = patient.dateOfAdmission.getFormattedDateFromString()
                checkingPatient?.wardNumber = Int16(patient.ward.wardNumber)
                completionHanlder?(.failure(FetchingError.thereIsNoSuchPatient))
                savePatient(patient: checkingPatient)
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
    
    
    public func fetchLabDataFromCoreData (for patient: Patient, predicateArg: String? = nil, completionHandler: @escaping (_ : [AnalysisType]) -> Void) {
        
        var labFindings = [AnalysisType]()
        let request : NSFetchRequest<ManagedLabData> = ManagedLabData.fetchRequest()
        if let arg = predicateArg {
            request.predicate = NSPredicate(format: "SELF CONTAINS %@", "\(arg)")
        }
        do {
            let fetchAnalysesFromCoreData = try self.context.fetch(request)
            
            for fetchedAnalysis in fetchAnalysesFromCoreData {
                let analysisType = AnalysisType(analysis: Analysis(data: fetchedAnalysis.data!, date: fetchedAnalysis.date!.getFormattedDate()), evnUslugaID: fetchedAnalysis.evnUslugaID!, evnXMLID: fetchedAnalysis.evnXMLID!)
                labFindings.append(analysisType)
            }
            completionHandler(labFindings)
        } catch let error {
            print("\(FetchingError.unableToFetchAnalysisDataFromCoreData.rawValue): \(error.localizedDescription)")
        }
        
        
    }
    
    
    public func savePatient (patient: ManagedPatient?) {
        
        guard let patient = patient else {
            return
        }

        let savingPatient = ManagedPatient(context: context)
        savingPatient.patientName = patient.patientName
        savingPatient.patientID = patient.patientID
        savingPatient.dateOfAdmission = patient.dateOfAdmission
        savingPatient.wardNumber = patient.wardNumber
            
        if context.hasChanges {
            do {
                try self.context.save()
            } catch let error {
                print("\(SavingError.unableToSavePatient.rawValue): \(error)")
            }
        }
    }
    
    func deletePatient (patient: ManagedPatient?) {
        
        guard let patient = patient else {
            return
        }
        
        context.delete(patient)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print("\(SavingError.unableToProperlyDeletePatient.rawValue): \(error)")
            }
        }
    }
    
    func saveLabData (with analysisType: [AnalysisType]) {
        
        analysisType.forEach { analysis in
            let managedLabData = ManagedLabData(context: context)
            managedLabData.evnXMLID = analysis.evnXMLID
            managedLabData.evnUslugaID = analysis.evnUslugaID
            managedLabData.date = analysis.analysis.date.getFormattedDateFromString()
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



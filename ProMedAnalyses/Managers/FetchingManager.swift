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
        
    private let context = CoreDataStack(modelName: "ProMedAnalyses").managedContext
    
    private init () { }
    
    enum FetchingError: String, Error {
        case unableToFetchPatientFromCoreData = "Unable to fetch patient from CoreData"
        case unableToFetchAnalysisDataFromCoreData = "Unable to fetch analysis data from CoreData"
    }
    
    enum SavingError: String, Error {
        case unableToSavePatient = "Unable to save patient"
        case unableToProperlyDeletePatient = "Unable to properly delete patient"
        case unableToSaveAnalysis = "Unable to save analysis"
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
    
    
    public func savePatient (patientName: String, patientID: String, dateOfAdmission: String, wardNumber: Int16) {
        
        let person = ManagedPatient(context: context)
        person.patientName = patientName
        person.patientID = patientID
        person.dateOfAdmission = dateOfAdmission.getFormattedDateFromString()
        person.wardNumber = wardNumber
        
        do {
            try self.context.save()
        } catch let error {
            print("\(SavingError.unableToSavePatient.rawValue): \(error)")
        }
        
    }
    
    func deletePatient (patientName: String, patientID: String, dateOfAdmission: String, wardNumber: Int16) {
        
        let person = ManagedPatient(context: context)
        person.patientName = patientName
        person.patientID = patientID
        person.dateOfAdmission = dateOfAdmission.getFormattedDateFromString()
        person.wardNumber = wardNumber
        
        context.delete(person)
        
        do {
            try context.save()
        } catch let error {
            print("\(SavingError.unableToProperlyDeletePatient.rawValue): \(error)")
        }
        
    }
    
    func saveLabData (for patient: ManagedPatient, with data: [[String]], date: String, labID: String, xmlID: String) {
        
        
        let managedLabData = ManagedLabData(context: context)
        managedLabData.evnXMLID = xmlID
        managedLabData.evnUslugaID = labID
        managedLabData.date = date.getFormattedDateFromString()
        managedLabData.data = data
        
        patient.addToToAnalysis(managedLabData)
        
        do {
            try self.context.save()
        } catch let error {
            print("\(SavingError.unableToSaveAnalysis.rawValue): \(error)")
        }
        
    }
    
}



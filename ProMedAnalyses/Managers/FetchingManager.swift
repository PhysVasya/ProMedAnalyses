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
    
    private var patients = [Patient]()
    private var labFindings = [Analysis]()
    
    private let context = CoreDataStack(modelName: "ProMedAnalyses").managedContext
    
    private init () { }
    
    
    public func fetchPatientsFromCoreData (completionHandler: (_ : [Patient])->Void) {
        var fetchedPatients = [Patient]()
        let request : NSFetchRequest<ManagedPatient> = ManagedPatient.fetchRequest()
        do {
            let fetchedPatientsFromCoreData = try self.context.fetch(request)
            for fetchedPatient in fetchedPatientsFromCoreData {
                let patient = Patient(name: fetchedPatient.patientName!, dateOfAdmission: fetchedPatient.dateOfAdmission!, ward: Ward(wardNumber: Int(fetchedPatient.wardNumber), wardType: .fourMan), patientID: fetchedPatient.patientID!, evnID: fetchedPatient.labID!, labIDs: fetchedPatient.idsToFetchAnalyses!)
                fetchedPatients.append(patient)
            }
            patients = fetchedPatients
            completionHandler(fetchedPatients)
            
        } catch {
            
        }
        
    }
    
    
    public func fetchLabDataFromCoreData (for patient: Patient, predicateArg: String? = nil, completionHandler: @escaping (_ : [Analysis]) -> Void) {
        
        DispatchQueue.main.async {
            let request : NSFetchRequest<ManagedLabData> = ManagedLabData.fetchRequest()
            if let arg = predicateArg {
                request.predicate = NSPredicate(format: "SELF CONTAINS %@", "\(arg)")
            }
            var labFindings = [Analysis]()
            do {
                let fetchAnalysesFromCoreData = try self.context.fetch(request)
                
                for fetchedAnalysis in fetchAnalysesFromCoreData {
                    
                    if patient.labIDs.contains(fetchedAnalysis.labID!) {
                        let analysis = Analysis(rows: fetchedAnalysis.data!, dateForHeaderInSection: fetchedAnalysis.date!, headerForAnalysis: fetchedAnalysis.header!)
                        labFindings.append(analysis)
                        
                    }
                }
                completionHandler(labFindings)
            } catch let error {
                print("Error fetching analyses data from coredata: \(error.localizedDescription)")
            }
            
        }
    }
    
    
    public func savePatient (patientName: String, patientID: String, dateOfAdmission: String, evnID: String, idsForAnalyses: [String], wardNumber: Int16) {
        
        DispatchQueue.main.async {
            
            //Creating an instance of ManagedObject
            guard let entity = NSEntityDescription.entity(forEntityName: K.CoreData.managedPatient, in: self.context) else {
                return
            }
            let person = NSManagedObject(entity: entity, insertInto: self.context) as! ManagedPatient
            person.patientName = patientName
            person.patientID = patientID
            person.dateOfAdmission = dateOfAdmission
            person.labID = evnID
            person.idsToFetchAnalyses = idsForAnalyses
            person.wardNumber = wardNumber
            
            do {
                try self.context.save()
            } catch let error {
                print("Error saving patient: \(error)")
            }
        }
    }
    
    func deletePatient (patientName: String, patientID: String, dateOfAdmission: String, evnID: String, idsForAnalyses: [String], wardNumber: Int16) {
        
        guard let entity = NSEntityDescription.entity(forEntityName: K.CoreData.managedPatient, in: context) else {
            return
        }
        
        let person = NSManagedObject(entity: entity, insertInto: context) as! ManagedPatient
        person.patientName = patientName
        person.patientID = patientID
        person.dateOfAdmission = dateOfAdmission
        person.labID = evnID
        person.idsToFetchAnalyses = idsForAnalyses
        person.wardNumber = wardNumber
        
        context.delete(person)
        
        do {
            try context.save()
        } catch let error {
            print("Error deleting and saving data: \(error)")
        }
        
    }
    
    func saveLabData (data: [[String]], date: String, header: [String], labID: String, xmlID: String) {
        
        DispatchQueue.main.async {
            //Creating a new instance of ManagedObject
            guard let entity = NSEntityDescription.entity(forEntityName: K.CoreData.managedLabData, in: self.context) else {
                return
            }
            let labData = NSManagedObject(entity: entity, insertInto: self.context) as! ManagedLabData
            labData.labID = labID
            labData.data = data
            labData.date = date
            labData.header = header
            labData.xmlID = xmlID
            
            do {
                try self.context.save()
            } catch let error {
                print("Error saving lab data: \(error)")
            }
        }
    }
    
}



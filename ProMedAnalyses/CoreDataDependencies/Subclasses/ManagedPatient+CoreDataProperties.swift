//
//  ManagedPatient+CoreDataProperties.swift
//  
//
//  Created by Vasiliy Andreyev on 21.03.2022.
//
//

import Foundation
import CoreData


extension ManagedPatient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPatient> {
        return NSFetchRequest<ManagedPatient>(entityName: "ManagedPatient")
    }

    @NSManaged public var birthday: Date?
    @NSManaged public var dateOfAdmission: Date?
    @NSManaged public var patientID: Int64
    @NSManaged public var patientName: String?
    @NSManaged public var sex: String?
    @NSManaged public var wardNumber: Int16
    @NSManaged public var labsData: NSOrderedSet?
    @NSManaged public var patientsAnalyses: NSOrderedSet?
    
    @objc public var wrappedPatientID : Int {
        return Int(patientID)
    }

}

// MARK: Generated accessors for labsData
extension ManagedPatient {

    @objc(insertObject:inLabsDataAtIndex:)
    @NSManaged public func insertIntoLabsData(_ value: ManagedLabData, at idx: Int)

    @objc(removeObjectFromLabsDataAtIndex:)
    @NSManaged public func removeFromLabsData(at idx: Int)

    @objc(insertLabsData:atIndexes:)
    @NSManaged public func insertIntoLabsData(_ values: [ManagedLabData], at indexes: NSIndexSet)

    @objc(removeLabsDataAtIndexes:)
    @NSManaged public func removeFromLabsData(at indexes: NSIndexSet)

    @objc(replaceObjectInLabsDataAtIndex:withObject:)
    @NSManaged public func replaceLabsData(at idx: Int, with value: ManagedLabData)

    @objc(replaceLabsDataAtIndexes:withLabsData:)
    @NSManaged public func replaceLabsData(at indexes: NSIndexSet, with values: [ManagedLabData])

    @objc(addLabsDataObject:)
    @NSManaged public func addToLabsData(_ value: ManagedLabData)

    @objc(removeLabsDataObject:)
    @NSManaged public func removeFromLabsData(_ value: ManagedLabData)

    @objc(addLabsData:)
    @NSManaged public func addToLabsData(_ values: NSOrderedSet)

    @objc(removeLabsData:)
    @NSManaged public func removeFromLabsData(_ values: NSOrderedSet)

}

// MARK: Generated accessors for patientsAnalyses
extension ManagedPatient {

    @objc(insertObject:inPatientsAnalysesAtIndex:)
    @NSManaged public func insertIntoPatientsAnalyses(_ value: ManagedAnalysis, at idx: Int)

    @objc(removeObjectFromPatientsAnalysesAtIndex:)
    @NSManaged public func removeFromPatientsAnalyses(at idx: Int)

    @objc(insertPatientsAnalyses:atIndexes:)
    @NSManaged public func insertIntoPatientsAnalyses(_ values: [ManagedAnalysis], at indexes: NSIndexSet)

    @objc(removePatientsAnalysesAtIndexes:)
    @NSManaged public func removeFromPatientsAnalyses(at indexes: NSIndexSet)

    @objc(replaceObjectInPatientsAnalysesAtIndex:withObject:)
    @NSManaged public func replacePatientsAnalyses(at idx: Int, with value: ManagedAnalysis)

    @objc(replacePatientsAnalysesAtIndexes:withPatientsAnalyses:)
    @NSManaged public func replacePatientsAnalyses(at indexes: NSIndexSet, with values: [ManagedAnalysis])

    @objc(addPatientsAnalysesObject:)
    @NSManaged public func addToPatientsAnalyses(_ value: ManagedAnalysis)

    @objc(removePatientsAnalysesObject:)
    @NSManaged public func removeFromPatientsAnalyses(_ value: ManagedAnalysis)

    @objc(addPatientsAnalyses:)
    @NSManaged public func addToPatientsAnalyses(_ values: NSOrderedSet)

    @objc(removePatientsAnalyses:)
    @NSManaged public func removeFromPatientsAnalyses(_ values: NSOrderedSet)

}

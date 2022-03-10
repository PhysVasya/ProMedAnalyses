//
//  ManagedPatient+CoreDataProperties.swift
//  
//
//  Created by Vasiliy Andreyev on 07.03.2022.
//
//

import Foundation
import CoreData


extension ManagedPatient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPatient> {
        return NSFetchRequest<ManagedPatient>(entityName: "ManagedPatient")
    }

    @NSManaged public var dateOfAdmission: Date?
    @NSManaged public var patientID: String?
    @NSManaged public var patientName: String?
    @NSManaged public var wardNumber: Int16
    @NSManaged public var analysis: NSOrderedSet?

    
}

// MARK: Generated accessors for analysis
extension ManagedPatient {

    @objc(insertObject:inAnalysisAtIndex:)
    @NSManaged public func insertIntoAnalysis(_ value: ManagedLabData, at idx: Int)

    @objc(removeObjectFromAnalysisAtIndex:)
    @NSManaged public func removeFromAnalysis(at idx: Int)

    @objc(insertAnalysis:atIndexes:)
    @NSManaged public func insertIntoAnalysis(_ values: [ManagedLabData], at indexes: NSIndexSet)

    @objc(removeAnalysisAtIndexes:)
    @NSManaged public func removeFromAnalysis(at indexes: NSIndexSet)

    @objc(replaceObjectInAnalysisAtIndex:withObject:)
    @NSManaged public func replaceAnalysis(at idx: Int, with value: ManagedLabData)

    @objc(replaceAnalysisAtIndexes:withAnalysis:)
    @NSManaged public func replaceAnalysis(at indexes: NSIndexSet, with values: [ManagedLabData])

    @objc(addAnalysisObject:)
    @NSManaged public func addToAnalysis(_ value: ManagedLabData)

    @objc(removeAnalysisObject:)
    @NSManaged public func removeFromAnalysis(_ value: ManagedLabData)

    @objc(addAnalysis:)
    @NSManaged public func addToAnalysis(_ values: NSOrderedSet)

    @objc(removeAnalysis:)
    @NSManaged public func removeFromAnalysis(_ values: NSOrderedSet)

}

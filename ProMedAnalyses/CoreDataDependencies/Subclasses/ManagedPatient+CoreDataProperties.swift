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
    @NSManaged public var toAnalysis: NSOrderedSet?

}

// MARK: Generated accessors for toAnalysis
extension ManagedPatient {

    @objc(insertObject:inToAnalysisAtIndex:)
    @NSManaged public func insertIntoToAnalysis(_ value: ManagedLabData, at idx: Int)

    @objc(removeObjectFromToAnalysisAtIndex:)
    @NSManaged public func removeFromToAnalysis(at idx: Int)

    @objc(insertToAnalysis:atIndexes:)
    @NSManaged public func insertIntoToAnalysis(_ values: [ManagedLabData], at indexes: NSIndexSet)

    @objc(removeToAnalysisAtIndexes:)
    @NSManaged public func removeFromToAnalysis(at indexes: NSIndexSet)

    @objc(replaceObjectInToAnalysisAtIndex:withObject:)
    @NSManaged public func replaceToAnalysis(at idx: Int, with value: ManagedLabData)

    @objc(replaceToAnalysisAtIndexes:withToAnalysis:)
    @NSManaged public func replaceToAnalysis(at indexes: NSIndexSet, with values: [ManagedLabData])

    @objc(addToAnalysisObject:)
    @NSManaged public func addToToAnalysis(_ value: ManagedLabData)

    @objc(removeToAnalysisObject:)
    @NSManaged public func removeFromToAnalysis(_ value: ManagedLabData)

    @objc(addToAnalysis:)
    @NSManaged public func addToToAnalysis(_ values: NSOrderedSet)

    @objc(removeToAnalysis:)
    @NSManaged public func removeFromToAnalysis(_ values: NSOrderedSet)

}

//
//  ManagedLabData+CoreDataProperties.swift
//  
//
//  Created by Vasiliy Andreyev on 14.03.2022.
//
//

import Foundation
import CoreData


extension ManagedLabData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedLabData> {
        return NSFetchRequest<ManagedLabData>(entityName: "ManagedLabData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var evnUslugaID: String?
    @NSManaged public var evnXMLID: String?
    @NSManaged public var name: String?
    @NSManaged public var patient: ManagedPatient?
    @NSManaged public var analysis: NSOrderedSet?

}

// MARK: Generated accessors for analysis
extension ManagedLabData {

    @objc(insertObject:inAnalysisAtIndex:)
    @NSManaged public func insertIntoAnalysis(_ value: ManagedAnalysis, at idx: Int)

    @objc(removeObjectFromAnalysisAtIndex:)
    @NSManaged public func removeFromAnalysis(at idx: Int)

    @objc(insertAnalysis:atIndexes:)
    @NSManaged public func insertIntoAnalysis(_ values: [ManagedAnalysis], at indexes: NSIndexSet)

    @objc(removeAnalysisAtIndexes:)
    @NSManaged public func removeFromAnalysis(at indexes: NSIndexSet)

    @objc(replaceObjectInAnalysisAtIndex:withObject:)
    @NSManaged public func replaceAnalysis(at idx: Int, with value: ManagedAnalysis)

    @objc(replaceAnalysisAtIndexes:withAnalysis:)
    @NSManaged public func replaceAnalysis(at indexes: NSIndexSet, with values: [ManagedAnalysis])

    @objc(addAnalysisObject:)
    @NSManaged public func addToAnalysis(_ value: ManagedAnalysis)

    @objc(removeAnalysisObject:)
    @NSManaged public func removeFromAnalysis(_ value: ManagedAnalysis)

    @objc(addAnalysis:)
    @NSManaged public func addToAnalysis(_ values: NSOrderedSet)

    @objc(removeAnalysis:)
    @NSManaged public func removeFromAnalysis(_ values: NSOrderedSet)

}

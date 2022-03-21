//
//  ManagedLabData+CoreDataProperties.swift
//  
//
//  Created by Vasiliy Andreyev on 21.03.2022.
//
//

import Foundation
import CoreData


extension ManagedLabData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedLabData> {
        return NSFetchRequest<ManagedLabData>(entityName: "ManagedLabData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var evnUslugaID: Int64
    @NSManaged public var evnXMLID: Int64
    @NSManaged public var name: String?
    @NSManaged public var analyses: NSOrderedSet?
    @NSManaged public var patient: ManagedPatient?

}

// MARK: Generated accessors for analyses
extension ManagedLabData {

    @objc(insertObject:inAnalysesAtIndex:)
    @NSManaged public func insertIntoAnalyses(_ value: ManagedAnalysis, at idx: Int)

    @objc(removeObjectFromAnalysesAtIndex:)
    @NSManaged public func removeFromAnalyses(at idx: Int)

    @objc(insertAnalyses:atIndexes:)
    @NSManaged public func insertIntoAnalyses(_ values: [ManagedAnalysis], at indexes: NSIndexSet)

    @objc(removeAnalysesAtIndexes:)
    @NSManaged public func removeFromAnalyses(at indexes: NSIndexSet)

    @objc(replaceObjectInAnalysesAtIndex:withObject:)
    @NSManaged public func replaceAnalyses(at idx: Int, with value: ManagedAnalysis)

    @objc(replaceAnalysesAtIndexes:withAnalyses:)
    @NSManaged public func replaceAnalyses(at indexes: NSIndexSet, with values: [ManagedAnalysis])

    @objc(addAnalysesObject:)
    @NSManaged public func addToAnalyses(_ value: ManagedAnalysis)

    @objc(removeAnalysesObject:)
    @NSManaged public func removeFromAnalyses(_ value: ManagedAnalysis)

    @objc(addAnalyses:)
    @NSManaged public func addToAnalyses(_ values: NSOrderedSet)

    @objc(removeAnalyses:)
    @NSManaged public func removeFromAnalyses(_ values: NSOrderedSet)

}

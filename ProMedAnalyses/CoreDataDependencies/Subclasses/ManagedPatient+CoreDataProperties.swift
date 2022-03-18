//
//  ManagedPatient+CoreDataProperties.swift
//  
//
//  Created by Vasiliy Andreyev on 14.03.2022.
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
    @NSManaged public var sex: String?
    @NSManaged public var birthday: Date?
    @NSManaged public var labData: NSOrderedSet?

}

// MARK: Generated accessors for labData
extension ManagedPatient {

    @objc(insertObject:inLabDataAtIndex:)
    @NSManaged public func insertIntoLabData(_ value: ManagedLabData, at idx: Int)

    @objc(removeObjectFromLabDataAtIndex:)
    @NSManaged public func removeFromLabData(at idx: Int)

    @objc(insertLabData:atIndexes:)
    @NSManaged public func insertIntoLabData(_ values: [ManagedLabData], at indexes: NSIndexSet)

    @objc(removeLabDataAtIndexes:)
    @NSManaged public func removeFromLabData(at indexes: NSIndexSet)

    @objc(replaceObjectInLabDataAtIndex:withObject:)
    @NSManaged public func replaceLabData(at idx: Int, with value: ManagedLabData)

    @objc(replaceLabDataAtIndexes:withLabData:)
    @NSManaged public func replaceLabData(at indexes: NSIndexSet, with values: [ManagedLabData])

    @objc(addLabDataObject:)
    @NSManaged public func addToLabData(_ value: ManagedLabData)

    @objc(removeLabDataObject:)
    @NSManaged public func removeFromLabData(_ value: ManagedLabData)

    @objc(addLabData:)
    @NSManaged public func addToLabData(_ values: NSOrderedSet)

    @objc(removeLabData:)
    @NSManaged public func removeFromLabData(_ values: NSOrderedSet)

}

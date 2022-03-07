//
//  ManagedLabData+CoreDataProperties.swift
//  
//
//  Created by Vasiliy Andreyev on 07.03.2022.
//
//

import Foundation
import CoreData


extension ManagedLabData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedLabData> {
        return NSFetchRequest<ManagedLabData>(entityName: "ManagedLabData")
    }

    @NSManaged public var data: [[String]]?
    @NSManaged public var date: Date?
    @NSManaged public var evnUslugaID: String?
    @NSManaged public var evnXMLID: String?
    @NSManaged public var patient: ManagedPatient?

}

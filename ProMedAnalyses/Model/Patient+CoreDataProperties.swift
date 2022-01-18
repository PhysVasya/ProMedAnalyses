//
//  Patient+CoreDataProperties.swift
//  
//
//  Created by Vasiliy Andreyev on 18.01.2022.
//
//

import Foundation
import CoreData


extension ManagedPatient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPatient> {
        return NSFetchRequest<ManagedPatient>(entityName: "ManagedPatient")
    }

    @NSManaged public var dateOfAdmission: String
    @NSManaged public var labID: String
    @NSManaged public var patientID: String
    @NSManaged public var patientName: String
    @NSManaged public var idsToFetchAnalyses: [String]

}

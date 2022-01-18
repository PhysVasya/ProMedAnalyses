//
//  LabData+CoreDataProperties.swift
//  
//
//  Created by Vasiliy Andreyev on 19.01.2022.
//
//

import Foundation
import CoreData


extension ManagedLabData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedLabData> {
        return NSFetchRequest<ManagedLabData>(entityName: "ManagedLabData")
    }

    @NSManaged public var data: [String]
    @NSManaged public var header: [String]
    @NSManaged public var labID: String
    @NSManaged public var date: String

}

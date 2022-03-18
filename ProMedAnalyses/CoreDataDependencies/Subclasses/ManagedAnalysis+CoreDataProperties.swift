//
//  ManagedAnalysis+CoreDataProperties.swift
//  
//
//  Created by Vasiliy Andreyev on 14.03.2022.
//
//

import Foundation
import CoreData


extension ManagedAnalysis {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedAnalysis> {
        return NSFetchRequest<ManagedAnalysis>(entityName: "ManagedAnalysis")
    }

    @NSManaged public var name: String?
    @NSManaged public var value: String?
    @NSManaged public var labData: ManagedLabData?

}

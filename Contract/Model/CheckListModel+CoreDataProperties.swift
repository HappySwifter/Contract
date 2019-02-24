//
//  CheckListModel+CoreDataProperties.swift
//  
//
//  Created by Артем Валиев on 20/12/2018.
//
//

import Foundation
import CoreData


extension CheckListModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CheckListModel> {
        return NSFetchRequest<CheckListModel>(entityName: "CheckListModel")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var requisits: String?
    @NSManaged public var trebovaniya: NSObject?
    @NSManaged public var requirements: NSSet?

    @NSManaged public var date: Date?

}

// MARK: Generated accessors for requirements
extension CheckListModel {

    @objc(addRequirementsObject:)
    @NSManaged public func addToRequirements(_ value: RequirementModel)

    @objc(removeRequirementsObject:)
    @NSManaged public func removeFromRequirements(_ value: RequirementModel)

    @objc(addRequirements:)
    @NSManaged public func addToRequirements(_ values: NSSet)

    @objc(removeRequirements:)
    @NSManaged public func removeFromRequirements(_ values: NSSet)

}

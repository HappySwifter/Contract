//
//  RequirementModel+Extensions.swift
//  Contract
//
//  Created by Артем Валиев on 19/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import CoreData

extension RequirementModel {
    
    @nonobjc public class func createNew() -> RequirementModel {
        return NSEntityDescription.insertNewObject(forEntityName: "RequirementModel", into: context) as! RequirementModel
    }

}

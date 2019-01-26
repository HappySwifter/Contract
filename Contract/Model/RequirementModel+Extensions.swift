//
//  RequirementModel+Extensions.swift
//  Contract
//
//  Created by Артем Валиев on 19/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import CoreData
import SWXMLHash

extension RequirementModel {
    
    @nonobjc public class func createNew() -> RequirementModel {
        return NSEntityDescription.insertNewObject(forEntityName: "RequirementModel", into: context) as! RequirementModel
    }

    class func saveObjects(checkListId: String, xmlObjects: [XMLIndexer]) -> [RequirementModel] {
        
        guard let checkListMidel: CheckListModel = getObjects(withId: checkListId).first else {
            Log("Нет такого чеклиста в базе", type: .error)
            return []
        }
        
        if xmlObjects.count == 0 {
            print("Пришел пустой массив требований")
        } else {
//            clearRequirementsTemplateFor(checkListId: checkListId)
            //            let _: RequirementTemplate? = clearEntity()
        }
        
        var objects = [RequirementModel]()
        for xml in xmlObjects {
            if let name = xml["a:REQUIREMENT"].element?.text, name.count > 0 {
                let object = createNew()
                object.title = name
                objects.append(object)
            }
        }
        appDelegate.saveContext()
        return objects
    }
    
//    class func clearRequirementsTemplateFor(checkListId: String) {
//        let fetchRequest = RequirementTemplate.requirementTemplateFetchRequest()
//        let predicate = NSPredicate(format: "checkListId = %@", checkListId)
//        fetchRequest.predicate = predicate
//
//        do {
//            let result = try context.fetch(fetchRequest)
//            result.forEach { (templ) in
//                context.delete(templ)
//            }
//        } catch {
//            assert(false, error.localizedDescription)
//        }
//    }
}

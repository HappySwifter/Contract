//
//  RequirementTemplate+Extensions.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 06/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import CoreData
import SWXMLHash

extension RequirementTemplate {
    @nonobjc public class func createNew() -> RequirementTemplate {
        return NSEntityDescription.insertNewObject(forEntityName: "RequirementTemplate", into: context) as! RequirementTemplate
    }
    
    private class func requirementTemplateFetchRequest() -> NSFetchRequest<RequirementTemplate> {
        return NSFetchRequest<RequirementTemplate>(entityName: "RequirementTemplate")
    }
    
    class func saveObjects(checkListId: String, xmlObjects: [XMLIndexer]) -> [RequirementTemplate] {
        
        if xmlObjects.count == 0 {
            print("Пришел пустой массив объектов")
        } else {
            Log("Загружено \(xmlObjects.count) шаблонов вопросов", type: .info)
            clearRequirementsTemplateFor(checkListId: checkListId)
//            let _: RequirementTemplate? = clearEntity()
        }
        
        var objects = [RequirementTemplate]()
        for xml in xmlObjects {
    
            if let name = xml["a:REQUIREMENT"].element?.text, name.count > 0 {
                let object = createNew()
                object.name = name
                object.checkListId = checkListId
                objects.append(object)
            }
        }
        appDelegate.saveContext()
        return objects
    }
    
    
    class func clearRequirementsTemplateFor(checkListId: String) {
        let fetchRequest = RequirementTemplate.requirementTemplateFetchRequest()
        let predicate = NSPredicate(format: "checkListId = %@", checkListId)
        fetchRequest.predicate = predicate
        
        do {
            let result = try context.fetch(fetchRequest)
            result.forEach { (templ) in
                context.delete(templ)
            }
        } catch {
            assert(false, error.localizedDescription)
        }
    }



}

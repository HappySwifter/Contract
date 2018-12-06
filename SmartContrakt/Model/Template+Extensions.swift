//
//  ObjectModel+Extensions.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 27/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import CoreData
import SWXMLHash

extension TemplateModel {
    @nonobjc public class func createNew() -> TemplateModel {
        return NSEntityDescription.insertNewObject(forEntityName: "TemplateModel", into: context) as! TemplateModel
    }
    
    class func saveObjects(xmlObjects: [XMLIndexer]) -> [TemplateModel] {
        
        if xmlObjects.count == 0 {
            print("Пришел пустой массив объектов")
        }
        
        var objects = [TemplateModel]()
        for xml in xmlObjects {
            
            let id = xml["a:ID"].element!.text
            
            let model: TemplateModel
            if let c: TemplateModel = getObjects(withId: id).first {
                model = c
            } else {
                model = createNew()
                model.id = id
            }
            
            model.name = xml["a:TITLE"].element!.text
            model.requisits = xml["a:REQUISITES"].element!.text
            
            objects.append(model)
        }
        appDelegate.saveContext()
        return objects
        
    }
    
    func addRequirementTemplates(data: [RequirementTemplate]) {
        for requirTemp in data {
            addToRequirementTemplates(requirTemp)
        }
    }
}

class TemplateCoreData {
    func getTemplates() -> [TemplateModel] {
        let templates: [TemplateModel] = getObjects()
        return templates
    }
}

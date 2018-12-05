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
        } else {
            let _: TemplateModel? = clearEntity()
        }
        
        var objects = [TemplateModel]()
        for xml in xmlObjects {
            let object = createNew()
            object.name = xml["a:TITLE"].element!.text
            object.requisits = xml["a:REQUISITES"].element!.text
            objects.append(object)
        }
        appDelegate.saveContext()
        return objects
        
    }
}

class TemplateCoreData {
    func getTemplates() -> [TemplateModel] {
        let templates: [TemplateModel] = getObjects()
        return templates
    }
}

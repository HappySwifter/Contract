//
//  CheckListModel+Extensions.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 28/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import CoreData
import SWXMLHash

extension CheckListModel {
    @nonobjc public class func createNew() -> CheckListModel {
        return NSEntityDescription.insertNewObject(forEntityName: "CheckListModel", into: context) as! CheckListModel
    }
    
    /// Save from server responce
    ///
    /// - Parameter xmlObjects: xml
    /// - Returns: array
    class func saveObjects(xmlObjects: [XMLIndexer]) -> [CheckListModel] {
        
        if xmlObjects.count == 0 {
            print("Пришел пустой массив чеклистов")
        }
        var objects = [CheckListModel]()
        
        for xml in xmlObjects {
            if let id = xml["a:ID"].element?.text, id.count > 0 {
                let object: CheckListModel
                if let c: CheckListModel = getObjects(withId: id).first {
                    object = c
                } else {
                    object = createNew()
                    object.id = id
                }
                object.name = xml["a:TITLE"].element!.text
                object.requisits = xml["a:REQUISITES"].element!.text
                objects.append(object)
            } else {
                Log("ID is empty", type: .warning)
            }
        }
        appDelegate.saveContext()
        return objects
        
    }
    
    @discardableResult class func saveMyCheckList(with id: String,
                                                  name: String?,
                                                  requisits: String?,
                                                  requirementsTemplates: NSSet?) -> CheckListModel {
        
        let object: CheckListModel
        if let c: CheckListModel = getObjects(withId: id).first {
            object = c
        } else {
            object = createNew()
            object.id = id
        }
        
        object.name = name
        object.requisits = requisits

        if let requirementsTemplates = requirementsTemplates {
            for template in requirementsTemplates {
                if let template = template as? RequirementTemplate {
                    let req = RequirementModel.createNew()
                    req.title = template.name
                    object.addToRequirements(req)
                } else {
                    assert(false)
                }
            }
        } else {
            assert(false, "empty requirements template array")
        }

        

        appDelegate.saveContext()
        return object
        
    }
}

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
    class func saveObjects(xmlObjects: [XMLIndexer]) {
        
        if xmlObjects.count == 0 {
            print("Пришел пустой массив чеклистов")
        }
        
        for xml in xmlObjects {
            if let id = xml["a:ID"].element?.text, id.count > 0, let title = xml["a:TITLE"].element?.text, !title.isEmpty {
                let object: CheckListModel
                if let c: CheckListModel = getObjects(withId: id).first {
                    object = c
                } else {
                    object = createNew()
                    object.id = id
                }
                object.name = title
                object.requisits = xml["a:REQUISITES"].element!.text
            } else {
                Log("ID or Title is empty", type: .warning)
            }
        }
        appDelegate.saveContext()
    }
    
    @discardableResult class func saveMyCheckList(with id: String,
                                                  name: String?,
                                                  requisits: String?,
                                                  requirementsTemplates: NSSet?,
                                                  date: Date) -> CheckListModel {
        
        let object: CheckListModel
        if let c: CheckListModel = getObjects(withId: id).first {
            object = c
        } else {
            object = createNew()
            object.id = id
        }
        
        object.name = name
        object.requisits = requisits
        object.date = date
        
        if let requirementsTemplates = requirementsTemplates {
            for template in requirementsTemplates {
                if let template = template as? RequirementTemplate {
                    let req = RequirementModel.createNew()
                    req.title = template.name
                    req.isUploaded = false
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
    
    class func removeWith(id: String) {
        if let check: CheckListModel = getObjects(withId: id).first {
            context.delete(check)
            appDelegate.saveContext()
        }
    }
}

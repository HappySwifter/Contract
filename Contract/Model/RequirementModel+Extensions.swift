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

    /// Сохраняем новое требование в локальной базе и присваиваем его чеклисту
    ///
    /// - Parameters:
    ///   - checkListId: id чеклиста
    ///   - requirementId: id требования, полученное от сервера
    ///   - note: заметка
    ///   - yesNo: да нет
    ///   - text: текст требования
    /// - Returns: возвращает модель требования
    class func saveRequirement(checkListId: String, requirementId: String, note: String, yesNo: Bool, text: String) -> RequirementModel? {
        
        guard let checkListModel: CheckListModel = getObjects(withId: checkListId).first else {
            Log("Нет такого чеклиста в базе", type: .error)
            assert(false)
            return nil
        }
        
        let req: RequirementModel
        if let c: RequirementModel = getLocalRequirementFor(checllistId: checkListId, title: text) {
            Log("found local requirement. Setting server id \(requirementId) to it", type: .info)
            req = c
        } else {
            Log("Not found any local requirement with checkListId: \(checkListId) and title: \(text)", type: .error)
            req = createNew()
            req.title = text
            checkListModel.addToRequirements(req)
        }
        req.id = requirementId
        req.yesNo = yesNo as NSNumber
        req.note = note
        
        appDelegate.saveContext()
        return req
    }
    
    
    class func getLocalRequirementFor(checllistId: String, title: String) -> RequirementModel? {

        let fetchRequest = NSFetchRequest<RequirementModel>(entityName: "RequirementModel")
        fetchRequest.fetchLimit = 1
        
        let predicate = NSPredicate(format: "checkList.id = %@ and title = %@", checllistId, title)
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest).first
            return result
        } catch {
            Log("Error \(error.localizedDescription)", type: .error)
            return nil
        }
    }
    
    /// Сохранить или обновить серверные требования в локальной базе. Если какого-либо требование в базе еще не было, оно присвоится чеклисту
    ///
    /// - Parameters:
    ///   - checkListId: id чеклиста
    ///   - xmlObjects: серверные требования
    /// - Returns: массив локальных требований
    class func saveServerRequirements(checkListId: String, xmlObjects: [XMLIndexer]) -> [RequirementModel] {
        if xmlObjects.count == 0 {
            print("Пришел пустой массив серверных requirement")
            return []
        }
        
        guard let checkListModel: CheckListModel = getObjects(withId: checkListId).first else {
            Log("Нет такого чеклиста в базе", type: .error)
            assert(false)
            return []
        }
        
        var objects = [RequirementModel]()
        
        for xml in xmlObjects {
            
            let id = xml["a:ID"].element!.text
            
            let model: RequirementModel
            if let c: RequirementModel = getObjects(withId: id).first {
                model = c
            } else {
                model = createNew()
                model.id = id
                checkListModel.addToRequirements(model)
            }
            
            model.title = xml["a:REQUIREMENT"].element!.text
            model.note = xml["a:NOTE"].element!.text

            if let yesNo = xml["a:AVAILABILITY"].element?.text, !yesNo.isEmpty {
                model.yesNo = yesNo == "False" ? NSNumber(value: false) : NSNumber(value: true)
            } else {
                model.yesNo = nil
            }
            
            
            
            objects.append(model)
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



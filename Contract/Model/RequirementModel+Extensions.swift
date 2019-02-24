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

    /// Находим требование по ид чеклиста и тексту требования и устанавливаем у него новые поля
    ///   - note: заметка
    ///   - yesNo: да нет
    @discardableResult class func saveLocalRequirFor(checkListId: String, title: String, note: String, yesNo: Bool) -> RequirementModel? {
        if let req = findLocalRequirementFor(checllistId: checkListId, title: title) {
            req.yesNo = yesNo as NSNumber
            req.note = note
            req.isUploaded = false // установили новые данные локально. На сервере их еще нет
            appDelegate.saveContext()
            return req
        } else {
            return nil
        }
    }
    
    
    /// Сохраняем новое требование в локальной базе и присваиваем его чеклисту
    ///
    /// - Parameters:
    ///   - checkListId: id чеклиста
    ///   - requirementId: id требования, полученное от сервера
    ///   - text: текст требования
    /// - Returns: возвращает модель требования
    class func setServerId(checkListId: String, requirementId: String, text: String) -> RequirementModel? {
        if let model = findLocalRequirementFor(checllistId: checkListId, title: text) {
            Log("Setting server id \(requirementId) for requirement", type: .info)
            model.id = requirementId
            model.isUploaded = true // этот ответ пришел от сервера. Устанавливаем, что загружено на сервер
            appDelegate.saveContext()
            return model
        } else {
            assert(false)
            return nil
        }
    }
    
    
    private class func findLocalRequirementFor(checllistId: String, title: String) -> RequirementModel? {

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
            
            if let id = xml["a:ID"].element?.text, !id.isEmpty {
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
                model.isUploaded = true // раз загружено с сервера, значит там оно есть
                objects.append(model)
            }
        }
        appDelegate.saveContext()
        return objects
    }
    
}



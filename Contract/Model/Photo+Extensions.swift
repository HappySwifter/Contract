//
//  Photo+Extensions.swift
//  Contract
//
//  Created by Артем Валиев on 26/01/2019.
//  Copyright © 2019 Артем Валиев. All rights reserved.
//

import Foundation
import CoreData
import SWXMLHash

extension Photo {
    
    @nonobjc public class func createNew() -> Photo {
        return NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
    }
    
    /// Сохраняем локальное фото
    @discardableResult class func savePhotoFor(requirement: RequirementModel, data: String) -> Photo {
        let photo: Photo = createNew()
        photo.data = data
        photo.isUploaded = false
        requirement.addToPhotos(photo)
        appDelegate.saveContext()
        return photo
    }
    
    func deleteLocalPhotoFor(requirement: RequirementModel) {
        requirement.removeFromPhotos(self)
        managedObjectContext?.delete(self)
        appDelegate.saveContext()
    }
    
    
    /// Сохраняем ответ от сервера
    class func setServerId(id: String, data: String, requirementId: String) -> Photo? {
        if let photo = findLocalPhotoBy(reqId: requirementId, and: data) {
            photo.id = id
            photo.isUploaded = true
            appDelegate.saveContext()
            return photo
        } else {
            assert(false)
            return nil
        }
    }
    
    class func findLocalPhotoBy(reqId: String, and data: String) -> Photo? {
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        fetchRequest.fetchLimit = 1
        let predicate = NSPredicate(format: "requirement.id = %@ and data = %@", reqId, data)
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest).first
            return result
        } catch {
            Log("Error \(error.localizedDescription)", type: .error)
            return nil
        }
    }
    
    class func removeAllPhotosFor(requirementId: String) {
        guard let requirementModel: RequirementModel = getObjects(withId: requirementId).first else {
            Log("Нет такого требования в базе", type: .error)
            assert(false)
            return
        }
        if let photos = requirementModel.photos {
            requirementModel.removeFromPhotos(photos)
        }
        appDelegate.saveContext()
    }
    
    class func saveServerPhotos(xmlObjects: [XMLIndexer], reqId: String)  {
        if xmlObjects.count == 0 {
            Log("Пришел пустой массив фотографий с сервера", type: .info)
        } else if xmlObjects.count == 1,
            (xmlObjects.first!["a:base64Binary"].element?.text == nil ||
                xmlObjects.first!["a:base64Binary"].element?.text == "")
        {
            Log("Пришел пустой массив фотографий с сервера", type: .info)
        } else {
            removeAllPhotosFor(requirementId: reqId)
            
            for xml in xmlObjects {
                let id = xml["a:ID"].element!.text
                
                let photo: Photo
                if let c: Photo = getObjects(withId: id).first {
                    photo = c
                } else {
                    photo = createNew()
                    //            photo.id = id
                }
                photo.isUploaded = true
            }
            appDelegate.saveContext()
        }
        
        
    }
    
}


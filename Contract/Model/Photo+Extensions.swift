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
    
    
    class func savePhoto(id: String, data: String, requirementId: String) -> Photo? {
        
        guard let requirementModel: RequirementModel = getObjects(withId: requirementId).first else {
            Log("Нет такого требования в базе", type: .error)
            assert(false)
            return nil
        }
        
        let photo: Photo
        if let c: Photo = getObjects(withId: id).first {
            photo = c
        } else {
            photo = createNew()
            photo.id = id
            requirementModel.addToPhotos(photo)
        }
        photo.data = data
        appDelegate.saveContext()
        return photo
    }
    
    class func removeAllPhotosFor(requirementId: String) {
        guard let requirementModel: RequirementModel = getObjects(withId: requirementId).first else {
            Log("Нет такого требования в базе", type: .error)
            assert(false)
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
            }
            appDelegate.saveContext()
        }
        
        
    }
    
}


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
    
    
    class func savePhoto(xml: XMLIndexer) -> Photo {
        let id = xml["a:ID"].element!.text
        
        let photo: Photo
        if let c: Photo = getObjects(withId: id).first {
            photo = c
        } else {
            photo = createNew()
//            photo.id = id
        }
        return photo
    }
}

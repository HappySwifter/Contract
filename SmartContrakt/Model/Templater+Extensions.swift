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

extension ObjectModel {
    @nonobjc public class func createNew() -> ObjectModel {
        return NSEntityDescription.insertNewObject(forEntityName: "ObjectModel", into: context) as! ObjectModel
    }
    
    class func saveObjects(xmlObjects: [XMLIndexer]) -> [ObjectModel] {
        
        if xmlObjects.count == 0 {
            print("Пришел пустой массив объектов")
        }
        var objects = [ObjectModel]()
        
        for xml in xmlObjects {
            let id = xml["a:ID"].element!.text
            
            let object: ObjectModel
            if let c: ObjectModel = getObjects(withId: id).first {
                object = c
            } else {
                object = createNew()
                object.id = id
            }
            
            object.name = xml["a:TITLE"].element!.text
            object.recvisits = xml["a:REQUISITES"].element!.text
            
            objects.append(object)
        }
        
        return objects
        
    }
}

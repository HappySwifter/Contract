//
//  User+Extensions.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 25/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import CoreData
import SWXMLHash


func getObjects<T: NSManagedObject>(withId id: String? = nil,
                                          limit: Int? = nil,
                                          sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
    
    //        if T.description() == Car.description() {
    //            assert(false, "use getCart methods instead")
    //        }
    
    let fetchRequest = NSFetchRequest<T>(entityName: T.description())
    if let limit = limit {
        fetchRequest.fetchLimit = limit
    }
    fetchRequest.sortDescriptors = sortDescriptors
    
    if let id = id {
        let predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.predicate = predicate
    }
    do {
        let result = try context.fetch(fetchRequest)
        return result
        
    } catch {
        Log("Error \(error.localizedDescription)", type: .error)
        return []
    }
}

extension User {

    @nonobjc public class func createNew() -> User {
        return NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
    }
    
    
    
    
    
    class func saveUser(xml: XMLIndexer) -> User {
        let id = xml["a:ID"].element!.text
        
        let user: User
        if let c: User = getObjects(withId: id).first {
            user = c
        } else {
            user = createNew()
            user.id = id
        }
        
        user.fio = xml["a:ФИО"].element!.text
        user.doljnost = xml["a:Должность"].element!.text
        user.organisation = xml["a:Организация"].element!.text
        user.otdel = xml["a:Отдел"].element!.text
        user.mail = xml["a:Почта"].element!.text
        user.status = xml["a:Статус"].element!.text
        user.phone_home = xml["a:Телефон_моб"].element!.text
        user.phone_work = xml["a:Телефон_раб"].element!.text
        user.photoString = xml["a:Фото"].element!.text
        
        return user
    }
}

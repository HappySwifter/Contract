//
//  CheckListViewController.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 28/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

class CheckListViewController: UIViewController {
    var object: ObjectModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.getCheckList(action: API.Action.getCheckList(objectId: object.id!)) { (result) in
            switch result {
            case .Success(let objs):
                print(objs.count)
//                self?.objects = objs
            case .Failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}

//
//  MyCheckListCell.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 03/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

class MyCheckListCell: UITableViewCell {
    
    
    func configure(model: CheckListModel) {
        textLabel?.text = model.id! + ": " + (model.name ?? "")
        textLabel?.numberOfLines = 0
        detailTextLabel?.text = model.requisits
        detailTextLabel?.numberOfLines = 0
    }
}

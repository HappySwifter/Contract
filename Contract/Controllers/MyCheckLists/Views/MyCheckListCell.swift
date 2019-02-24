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
        var text = ""
        if let date = model.date {
            let form = DateFormatter()
            form.dateFormat = "dd.MM.YY"
            text = form.string(from: date)
            text += "\n"
        }
        textLabel?.text = text + (model.name ?? "")
        textLabel?.numberOfLines = 0
        detailTextLabel?.text = model.requisits
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.textColor = .darkGray
        imageView?.image = UIImage(named: "checkmark")
        
        if let requirs: [RequirementModel] = model.requirements?.toArray() {
            var isallRequirementsUploaded = true
            for req in requirs {
                if !req.isUploaded {
                    isallRequirementsUploaded = false
                }
            }
            if isallRequirementsUploaded {
                imageView?.image = UIImage(named: "checkmark")
            } else {
                imageView?.image = nil
            }
        }
        
    }
}

//
//  MenuVM.swift
//  Machine
//
//  Created by Артем Валиев on 04/08/2017.
//  Copyright © 2017 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

enum MenuObject: Int, CustomStringConvertible, CaseIterable {
    case Profile = 0
    case CheckList
    case Exit
    
    var description: String {
        switch self {
        case .Profile:
            return "Профиль"
        case .CheckList:
            return "Чек листы"
        case .Exit:
            return "Выход"
        }
    }

    var image: UIImage {
        switch self {
        case .Profile:
            return UIImage(named: "settingsMenu")!
        case .CheckList:
            return UIImage(named: "settingsMenu")!
        case .Exit:
            return UIImage(named: "settingsMenu")!
        }
    }

    var showDivider: Bool {
        switch self {
        case .Exit:
            return false
        default:
            return true
        }
    }
    
}

struct MenuVM {
    
    var selectedCellIndex: Int = 100
    
    func numberOfRows() -> Int {
        return MenuObject.allCases.count
    }
    
    func textFor(index: Int) -> String {
        return MenuObject(rawValue: index)!.description
    }

    func imageFor(index: Int) -> UIImage {
        return MenuObject(rawValue: index)!.image
    }
    
    func getMenuItemFor(index: Int) -> MenuObject {
        return MenuObject(rawValue: index)!
    }

    func showDividerFor(index: Int) -> Bool {
        return MenuObject(rawValue: index)!.showDivider
    }
    
    func viewModelForCell(at index: Int) -> MenuCellVM {
        let textForCell = textFor(index: index)
        let imageForCell = imageFor(index: index)
        let showDivider = showDividerFor(index: index)
        let isSelected = selectedCellIndex == index
        let cellVM = MenuCellVM(text: textForCell, isSelected: isSelected, image: imageForCell, showDivider: showDivider)
        return cellVM
    }
}

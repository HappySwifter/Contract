//
//  CheckList+Action.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 01/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import  UIKit

extension RequirementsViewController {
    @IBAction func rightPressed(sender: UIButton) {
        if let index = collectionView.indexPathsForVisibleItems.first?.item, index < (requirements.count) - 1 {
            sender.isEnabled = false
            collectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: true)
            delay(0.3) { [weak self] in
                self?.configureBottomView()
                sender.isEnabled = true
            }
        }
    }
    
    @IBAction func leftPressed(sender: UIButton) {
        if let index = collectionView.indexPathsForVisibleItems.first?.item, index > 0 {
            sender.isEnabled = false
            collectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: true)
            delay(0.3) { [weak self] in
                self?.configureBottomView()
                sender.isEnabled = true
            }
            
        }
    }
    
    func didEndScroll() {
        configureBottomView()
    }
}

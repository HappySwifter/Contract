//
//  CheckList+Collection.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 01/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

extension RequirementsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ItemCell
        cell.configure(model: requirements[indexPath.row], parent: self)
        cell.yesNoHandler = { [weak self] targetCell in
            if let ip = collectionView.indexPath(for: targetCell) {
                if let requirement = self?.requirements[ip.row] {
                    let request = Requirements.SetRequirement.Request(requirementId: requirement.id,
                                                                  requirementText: targetCell.textLabel.text,
                                                                  yesNo: targetCell.segmentedControl.selectedSegmentIndex == 0,
                                                                  note: targetCell.commentTextField.text)
                    self?.handleYesNoPress(request: request)
                }
                
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requirements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvSize = collectionView.frame.size
        return CGSize(width: cvSize.width  - (edgeInset * 2), height: cvSize.height  - (edgeInset * 2))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            didEndScroll()
        }
    }
    
    
    
}

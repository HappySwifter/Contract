//
//  ItemCell.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 01/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

class ItemCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    var photos = [UIImage]()

    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 1
    }
    
    func configure(model: CheckListModel) {
        textLabel.text = model.name
        collectionView.reloadData()
    }
}




extension ItemCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        if photos.count == 0 {
            cell.configure(photo: UIImage(named: "AddButton")!)
        } else {
            cell.configure(photo: photos[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count > 0 ? photos.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = collectionView.frame.size.height
        let maxH = collectionView.frame.size.width / CGFloat(maxPhotosCoint)
        let m = min(h, maxH)
        return CGSize(width: m, height: m)
    }

    
}


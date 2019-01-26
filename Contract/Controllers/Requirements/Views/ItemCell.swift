//
//  ItemCell.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 01/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ItemCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UITextView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    var photos = [UIImage]()
    var requirId: String!
    var parent: UIViewController!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 1
    }
    
    func configure(model: RequirementModel, parent: UIViewController) {
        self.parent = parent
        self.requirId = String(model.id)
        textLabel.text = model.title
        collectionView.reloadData()
    }
}




extension ItemCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        if photos.count == 0 {
            cell.configure(photoCellType: .add, requirId: requirId)
        } else {
            cell.configure(photoCellType: .photo(photo: photos[indexPath.item]), requirId: requirId)
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            switch cell.photoCellType {
            case .add:
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                UIViewController.topMostViewController()?.present(imagePicker, animated: true, completion: nil)
            case .photo(let photo):
                let contr = FullScreenImageVC()
                contr.image = photo
                parent.present(contr, animated: true, completion: nil)
            }
        }
    }
    
}


extension ItemCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[.imageURL] as! URL? {
            picker.dismiss(animated: true, completion: { [weak self] in
                guard let sSelf = self else { return }
                let provider = LocalFileImageDataProvider(fileURL: url)
                sSelf.imageView.kf.setImage(with: provider)
                
                if let data = try? Data(contentsOf: url) {
                    let string = data.base64EncodedString()
                    api.setPhotoForRequiremenrt(action: API.Action.setPhotoForRequiremenrt(id: sSelf.requirId, photoData: string), cb: { (result) in
                        
                    })
                }
            })
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

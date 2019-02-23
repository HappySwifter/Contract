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
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var photos = [Photo]()
    var requir: RequirementModel!
    var parent: UIViewController!
    var yesNoHandler: ((ItemCell) -> Void)?
    
    enum ViewType {
        case empty
        case valueFrom1To4
        case full
    }
    var collectionViewValueType: ViewType {
        if 1 ... 4 ~= photos.count {
            return .valueFrom1To4
        } else if photos.count >= 5 {
            return .full
        } else {
            return .empty
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 1
    }
    
    func configure(model: RequirementModel, parent: UIViewController) {
        self.parent = parent
        self.requir = model
        if let title = model.title, !title.isEmpty {
            textLabel.text = title
        } else {
            textLabel.text = "Без описания"
        }
        commentTextField.text = model.note
        if let yesNo = model.yesNo as? Bool {
            segmentedControl.selectedSegmentIndex = yesNo ? 0 : 1
        } else {
            segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
        
        photos = requir.photos?.toArray() ?? []
        photosCollectionView.reloadData()
    }
    
    @IBAction func yesNoTouched() {
        yesNoHandler?(self)
    }
}



/// Photos collection view
extension ItemCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        
        switch collectionViewValueType {
        case .empty:
            cell.configure(photoCellType: .add, requirId: requir.id)
        case .valueFrom1To4:
            if indexPath.item + 1 > photos.count {
                cell.configure(photoCellType: .add, requirId: requir.id)
            } else {
                let base64 = photos[indexPath.item].data!
                let data = Data(base64Encoded: base64)!
                let image = UIImage(data: data)!
                cell.configure(photoCellType: .photo(photo: image), requirId: requir.id!)
            }
        case .full:
            let base64 = photos[indexPath.item].data!
            let data = Data(base64Encoded: base64)!
            let image = UIImage(data: data)!
            cell.configure(photoCellType: .photo(photo: image), requirId: requir.id!)
            
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionViewValueType {
        case .empty:
            return 1
        case .valueFrom1To4:
            return photos.count + 1
        case .full:
            return photos.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = collectionView.frame.size.height
        let maxH = collectionView.frame.size.width / CGFloat(maxPhotosCoint)
        let m = min(h, maxH)
        return CGSize(width: realSize(55), height: realSize(55))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            switch cell.photoCellType {
            case .add:
                if let _ = requir.id {
                    let imagePicker = UIImagePickerController()
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    UIViewController.topMostViewController()?.present(imagePicker, animated: true, completion: nil)
                } else {
                    presentAlert(title: "Сначала выберите Да или Нет", text: "")
                }
                
            case .photo(let photo):
                let contr = FullScreenImageVC()
                contr.removeHandler = { [weak self] in
                    contr.dismiss(animated: true, completion: { [weak self] in
                        self?.deletePhotos()
                    })
                    
                }
                contr.image = photo
                parent.present(contr, animated: true, completion: nil)
            }
        }
    }
    
    private func deletePhotos() {
        
        if let reqId = requir.id {
            let alert = UIAlertController(title: "Удалить фото?", message: "Будут удалены все фото данного требованияы", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                api.deleteAllPhotosForRequirement(action: API.Action.deleteAllPhotosForRequirement(id: reqId), cb: { [weak self] (result) in
                    switch result {
                    case .Success:
                        self?.photos.removeAll()
                        self?.photosCollectionView.reloadData()
                    case .Failure(let error):
                        presentAlert(title: "Ошибка", text: error.localizedDescription)
                    }
                })
            })
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            UIViewController.topMostViewController()?.present(alert, animated: true, completion: nil)
   
        } else {
            Log("No id for requirement!", type: .error)
        }
    }
}


extension ItemCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[.imageURL] as! URL? {
            picker.dismiss(animated: true, completion: { [weak self] in
                guard let sSelf = self else { return }
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    let scaledImagedata = image!.jpegData(compressionQuality: 0.2)
                    let string = scaledImagedata!.base64EncodedString()
                    api.setPhotoForRequiremenrt(action: API.Action.setPhotoForRequiremenrt(id: sSelf.requir.id!, photoData: string), cb: { [weak self] (result) in
                        switch result {
                        case .Success(let photo):
                            self?.photos.append(photo)
                            self?.photosCollectionView.reloadData()
                        case .Failure(let error):
                            Log(error.localizedDescription, type: .error)
                        }
                    })
                }
            })
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

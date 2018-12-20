//
//  PhotoCell.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 01/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var requirId: String!

    override func didMoveToWindow() {
        super.didMoveToWindow()
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(tap)
    }
    
    func configure(photo: UIImage, requirId: String) {
        self.requirId = requirId
        imageView.image = photo
    }
    
    @objc func imageTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        UIViewController.topMostViewController()?.present(imagePicker, animated: true, completion: nil)
    }
}

extension PhotoCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[.imageURL] as! URL? {
            picker.dismiss(animated: true, completion: { [weak self] in
                guard let sSelf = self else { return }
                let provider = LocalFileImageDataProvider(fileURL: url)
                sSelf.imageView.kf.setImage(with: provider)
                
                if let data = try? Data(contentsOf: url) {
                    
                    let string = data.base64EncodedString()
                    api.uploadImage(action: API.Action.setPhotoForRequiremenrt(id: sSelf.requirId, photoData: string), cb: { (result) in
                        
                    })
                }
            })
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

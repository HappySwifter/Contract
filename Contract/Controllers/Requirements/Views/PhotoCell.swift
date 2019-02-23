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
    @IBOutlet weak var checkImageView: UIImageView!
    
    var photoCellType = PhotoCellType.add
    
    enum PhotoCellType {
        case photo(photo: Photo)
        case add
    }
    
    
    func configure(photoCellType: PhotoCellType) {
        self.photoCellType = photoCellType
        
        
        switch photoCellType {
        case .add:
            imageView.image = UIImage(named: "AddButton")!
            checkImageView.isHidden = true
        case .photo(let photo):
            let base64 = photo.data!
            let data = Data(base64Encoded: base64)!
            let image = UIImage(data: data)!
            imageView.image = image
            
            if photo.isUploaded {
                checkImageView.isHidden = false
            } else {
                checkImageView.isHidden = true
            }
        }
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

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
    var photoCellType = PhotoCellType.add
    
    enum PhotoCellType {
        case photo(photo: UIImage)
        case add
    }
    
    
    func configure(photoCellType: PhotoCellType, requirId: String) {
        self.requirId = requirId
        self.photoCellType = photoCellType
        
        switch photoCellType {
        case .add:
            imageView.image = UIImage(named: "AddButton")!
        case .photo(let photo):
            imageView.image = photo
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

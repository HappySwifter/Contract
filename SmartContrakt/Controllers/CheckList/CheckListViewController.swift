//
//  CheckListViewController.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 28/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

let maxPhotosCoint = 5


class CheckListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomTextLabel: UILabel!

    
    let edgeInset = realSize(10)
    
    var object: ObjectModel!
    
    
    var checkListItems = [CheckListModel]() {
        didSet {
            collectionView.reloadData()
            delay(0.3) { [weak self] in
                self?.configureBottomView()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lay = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        lay.sectionInset = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
        lay.minimumInteritemSpacing = edgeInset * 2
        lay.minimumLineSpacing = edgeInset * 2
        api.getCheckList(action: API.Action.getRequirementsFor(templateId: object.id!)) { [weak self] (result) in
            switch result {
            case .Success(let objs):
                self?.checkListItems = objs
            case .Failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func configureBottomView() {
        if let index = collectionView.indexPathsForVisibleItems.first?.item {
            bottomTextLabel.text = "\(index + 1) из \(checkListItems.count)"
        }
    }
    
}

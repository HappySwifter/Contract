//
//  RequirementsViewController.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 04/12/2018.
//  Copyright (c) 2018 Артем Валиев. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

let maxPhotosCoint = 5

protocol RequirementsDisplayLogic: class {
    func displaySomething(viewModel: Requirements.Something.ViewModel)
}

class RequirementsViewController: UIViewController, RequirementsDisplayLogic {
    var interactor: RequirementsBusinessLogic?
    var router: (NSObjectProtocol & RequirementsRoutingLogic & RequirementsDataPassing)?

  // MARK: Object lifecycle
  
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
  
  // MARK: Setup
  
  private func setup() {
    let viewController = self
    let interactor = RequirementsInteractor()
    let presenter = RequirementsPresenter()
    let router = RequirementsRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  
  
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomTextLabel: UILabel!
    
    let edgeInset = realSize(10)
    var object: CheckListModel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lay = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        lay.sectionInset = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
        lay.minimumInteritemSpacing = edgeInset * 2
        lay.minimumLineSpacing = edgeInset * 2
        
    }
    
    func configureBottomView() {
        if let index = collectionView.indexPathsForVisibleItems.first?.item {
            bottomTextLabel.text = "\(index + 1) из \(object.requirements?.count ?? 0)"
        }
    }
    

    func displaySomething(viewModel: Requirements.Something.ViewModel) {
        //nameTextField.text = viewModel.name
    }
    
}

//
//  CheckListsRouter.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 03/12/2018.
//  Copyright (c) 2018 Артем Валиев. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol CheckListsRoutingLogic
{
    func routeToRequirements(checkList: CheckListModel)
}

protocol CheckListsDataPassing
{
  var dataStore: CheckListsDataStore? { get }
}

class CheckListsRouter: NSObject, CheckListsRoutingLogic, CheckListsDataPassing
{
  weak var viewController: CheckListsViewController?
  var dataStore: CheckListsDataStore?
  
    
    func routeToRequirements(checkList: CheckListModel) {
        let contr = getController(forName: RequirementsViewController.self, showMenuButton: false)
        contr.object = checkList
        viewController?.navigationController?.pushViewController(contr, animated: true)
    }
  // MARK: Routing
  
  //func routeToSomewhere(segue: UIStoryboardSegue?)
  //{
  //  if let segue = segue {
  //    let destinationVC = segue.destination as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //  } else {
  //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
  //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //    navigateToSomewhere(source: viewController!, destination: destinationVC)
  //  }
  //}

  // MARK: Navigation
  
  //func navigateToSomewhere(source: CheckListsViewController, destination: SomewhereViewController)
  //{
  //  source.show(destination, sender: nil)
  //}
  
  // MARK: Passing data
  
  //func passDataToSomewhere(source: CheckListsDataStore, destination: inout SomewhereDataStore)
  //{
  //  destination.name = source.name
  //}
}

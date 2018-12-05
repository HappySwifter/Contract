//
//  CheckListsInteractor.swift
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

protocol CheckListsBusinessLogic
{
    func getMyCheckLists(request: CheckLists.Something.Request)
    func createNewCheckList(request: CheckLists.CreateCheckList.Request)
    func removeCheckList(request: CheckLists.RemoveCheckList.Request)
}

protocol CheckListsDataStore
{
  //var name: String { get set }
}

class CheckListsInteractor: CheckListsBusinessLogic, CheckListsDataStore
{

    
  var presenter: CheckListsPresentationLogic?
  let serverWorker = api
  //var name: String = ""
  
  // MARK: Do something
  
    func getMyCheckLists(request: CheckLists.Something.Request) {
        serverWorker?.getMyCheckLists(action: API.Action.getMyChecklists) { [weak self] result in
            switch result {
            case .Success(let checkLists):
                self?.displayCheckLists(models: checkLists)
            case .Failure(let error):
                presentAlert(title: "Ошибка", text: error.localizedDescription)
            }
        }
        
    }
    
    func createNewCheckList(request: CheckLists.CreateCheckList.Request) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let strDate = formatter.string(from: request.date)
        let action = API.Action.createCheckListFromTemplate(requisit: request.requisites, title: request.title, date: strDate)
        api.createCheckListFromTemplate(action: action) { [weak self] (result) in
            switch result {
            case .Success:
                let req = CheckLists.Something.Request()
                self?.getMyCheckLists(request: req)
            case .Failure(let error):
                presentAlert(title: "Ошибка", text: error.localizedDescription)
            }
        }
    }
    
    func removeCheckList(request: CheckLists.RemoveCheckList.Request) {
        api.removeCheckList(action: API.Action.deleteCheckList(checkListId: request.id)) { [weak self] (result) in
            switch result {
            case .Success:
                let req = CheckLists.Something.Request()
                self?.getMyCheckLists(request: req)
            case .Failure(let error):
                presentAlert(title: "Ошибка", text: error.localizedDescription)
            }
        }
    }
    
    
    func displayCheckLists(models: [CheckListModel]) {
        let res = CheckLists.Something.Response(checkLists: models)
        presenter?.displayCheckLists(response: res)
    }
}

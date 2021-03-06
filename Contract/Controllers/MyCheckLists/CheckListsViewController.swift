//
//  CheckListsViewController.swift
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
import RMDateSelectionViewController

protocol CheckListsDisplayLogic: class
{
  func displayCheckLists(viewModel: CheckLists.Something.ViewModel)
}

class CheckListsViewController: UIViewController, CheckListsDisplayLogic
{
  var interactor: CheckListsBusinessLogic?
  var router: (NSObjectProtocol & CheckListsRoutingLogic & CheckListsDataPassing)?

  // MARK: Object lifecycle
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
  {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: Setup
  
  private func setup()
  {
    let viewController = self
    let interactor = CheckListsInteractor()
    let presenter = CheckListsPresenter()
    let router = CheckListsRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  

    @IBOutlet weak var tableView: UITableView!
    var data = [CheckListModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        getCheckLists()

        
//        let contr = getController(forName: LoginViewController.self, showMenuButton: false)
//        setCenter(controller: contr)        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
  // MARK: Do something
  
  //@IBOutlet weak var nameTextField: UITextField!
  
  func getCheckLists()
  {
    let request = CheckLists.Something.Request()
    interactor?.getMyCheckLists(request: request)
  }
  
  func displayCheckLists(viewModel: CheckLists.Something.ViewModel)
  {
    self.data = viewModel.checkLists
    //nameTextField.text = viewModel.name
  }
    
    @IBAction func editPressed() {
        tableView.isEditing = !tableView.isEditing
        tableView.reloadData()
    }
    
    @IBAction func createNewTouched() {
        let templateController = getController(forName: TemplatesViewController.self, showMenuButton: false)
        templateController.selectHandler = { [weak self] template in
            self?.getDate() { [weak self] date in
                self?.navigationController?.popViewController(animated: true)
                let request = CheckLists.CreateCheckList.Request(model: template, date: date)
                self?.interactor?.createNewCheckList(request: request)
            }
        }
        navigationController!.pushViewController(templateController, animated: true)
    }
    
    func getDate(cb: @escaping (Date) -> Void) {
        let selectAction = RMAction<UIDatePicker>(title: "Выбрать", style: .done) { controller in
            cb(controller.contentView.date)
        }
        
        let cancelAction = RMAction<UIDatePicker>(title: "Отмена", style: .cancel) { _ in
        }
        
        let actionController = RMDateSelectionViewController(style: .white, title: nil, message: nil, select: selectAction, andCancel: cancelAction)!
        
        actionController.disableBouncingEffects = true
        actionController.disableMotionEffects = true
        actionController.disableBlurEffects = true
        
        actionController.datePicker.datePickerMode = .date
        actionController.datePicker.minuteInterval = 5
        actionController.datePicker.date = Date()
        
        present(actionController, animated: true, completion: nil)
    }
}


extension CheckListsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyCheckListCell
        cell.configure(model: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            if let modelId = data[indexPath.row].id {
                let req = CheckLists.RemoveCheckList.Request(id: modelId)
                interactor?.removeCheckList(request: req)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = data[indexPath.row]
        router?.routeToRequirements(checkList: model)
    }
}

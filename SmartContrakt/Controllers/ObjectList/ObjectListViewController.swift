//
//  ObjectListViewController.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 27/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

class ObjectListViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var objects = [ObjectModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        getObjects()
        
    }
    
    func getObjects() {
        api.getObjects(action: API.Action.getTemplates) { [weak self] (result) in
            switch result {
            case .Success(let objs):
                self?.objects = objs
            case .Failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension ObjectListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let obj = objects[indexPath.row]
        cell.textLabel?.text = obj.name
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = obj.recvisits
        cell.detailTextLabel?.numberOfLines = 0
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contr = getController(forName: CheckListViewController.self, showMenuButton: false)
        contr.object = objects[indexPath.row]
        navigationController?.pushViewController(contr, animated: true)
    }
}

//
//  MenuVC.swift
//  Machine
//
//  Created by Артем Валиев on 04/08/2017.
//  Copyright © 2017 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

class MenuVC: UITableViewController {

    var viewModel: MenuVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MenuVM()
        view.backgroundColor = UIColor(hexString: "fafafa")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.selectedCellIndex = getSelectedIndex()
        tableView.reloadData()
    }
    
    let headerHeight: CGFloat = realSize(90)
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHeight))
        view.backgroundColor = .white
        
        let imView = UIImageView(frame: CGRect(x: 20, y: 10, width: tableView.frame.size.width - 50, height: headerHeight - realSize(25)))
        imView.contentMode = .scaleAspectFit
        #if MEGAFON
        imView.image = #imageLiteral(resourceName: "megafon_logo")
        #else
        imView.image = #imageLiteral(resourceName: "logo")
        #endif
        
        view.addSubview(imView)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        let cellVM = viewModel.viewModelForCell(at: indexPath.row)
        cell.configure(withDelegate: cellVM, isSelected: indexPath.row == getSelectedIndex())
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            let ip = tableView.indexPath(for: cell)
            if ip != indexPath {
                cell.setSelected(false, animated: false)
            }
        }
        let item = viewModel.getMenuItemFor(index: indexPath.row)
        let contr: UIViewController
        switch item {
        case .Profile:
            contr = getController(forName: ProfileViewController.self, showMenuButton: true)
        case .CheckList:
            contr = getController(forName: ObjectListViewController.self, showMenuButton: true)
        case .Exit:
            CurrentUser.logout()
            contr = getController(forName: LoginViewController.self, showMenuButton: false)
        default:
            assert(false)
            return
        }
        setCenter(controller: contr)

    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MenuCell, let delegate = cell.delegate {
            cell.setSelected(delegate.isSelected, animated: false)
        }
    }
    
    func getSelectedIndex() -> Int {
        guard let navContr = evo_drawerController?.centerViewController as? UINavigationController else { return 100 }
        let controller = navContr.topViewController
        if controller is ProfileViewController {
            return MenuObject.Profile.rawValue
        } else if controller is ObjectListViewController {
            return MenuObject.CheckList.rawValue
        } else {
            return 100
        }
    }
    

}

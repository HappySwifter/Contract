//
//  ViewController.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 24/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import UIKit

class LoginViewController: UITableViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
        loginTextField.text = "jamsmp"
        passwordTextField.text = "12345"
        #endif
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    
    @IBAction func login() {
        guard let login = loginTextField.text, !login.isEmpty, let pass = passwordTextField.text, !pass.isEmpty else {
            return
        }
        
        api.login(action: API.Action.getSession(logn: login, pass: pass)) { [weak self] result in
            switch result {
            case .Success(let tuple):
                CurrentUser.save(user: tuple.user, token: tuple.token)
                let contr = getController(forName: ObjectListViewController.self, showMenuButton: true)
                self?.setCenter(controller: contr)
            case .Failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height - 80
    }

}


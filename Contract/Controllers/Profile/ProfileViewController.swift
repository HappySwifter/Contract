//
//  ProfileController.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 25/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var otdelLabel: UILabel!
    @IBOutlet weak var doljnostLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = CurrentUser.getUser() {
            nameLabel.text = user.fio
            organizationLabel.text = user.organisation
            otdelLabel.text = user.otdel
            doljnostLabel.text = user.doljnost
            emailLabel.text = user.mail
//            photoView.image = user.photoString
        } else {
            CurrentUser.logout()
            let contr = getController(forName: LoginViewController.self, showMenuButton: false)
            setCenter(controller: contr)
        }
    }
    
    
}

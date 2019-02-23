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
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var organizationLabel: UITextField!
    @IBOutlet weak var otdelLabel: UITextField!
    @IBOutlet weak var doljnostLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = CurrentUser.getUser() {
            nameLabel.text = user.fio
            organizationLabel.text = user.organisation
            otdelLabel.text = user.otdel
            doljnostLabel.text = user.doljnost
            emailLabel.text = user.mail
            
            if let photo = user.photoString {
                let data = Data(base64Encoded: photo)!
                let image = UIImage(data: data)!
                photoView.image = image
            }
            
        } else {
            CurrentUser.logout()
            let contr = getController(forName: LoginViewController.self, showMenuButton: false)
            setCenter(controller: contr)
        }
    }
    
    
}

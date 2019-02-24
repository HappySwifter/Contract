//
//  NoteViewController.swift
//  Contract
//
//  Created by Артем Валиев on 24/02/2019.
//  Copyright © 2019 Артем Валиев. All rights reserved.
//

import Foundation
import UIKit


class NoteViewController: UIViewController {
    
    @IBOutlet weak var myTextView: UITextView!
    var completionHandler: ((String) -> Void)?
    var initaltext: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Оставьте комментарий"
        let rightDrawerButton =  UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(savePressed))
        self.navigationItem.setRightBarButton(rightDrawerButton, animated: false)
        
        let leftDrawerButton =  UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPressed))
        self.navigationItem.setLeftBarButton(leftDrawerButton, animated: false)
        
        myTextView.font = UIFont.systemFont(ofSize: realSize(16))
        myTextView.text = initaltext
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myTextView.becomeFirstResponder()
    }
    
    @objc func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func savePressed() {
        completionHandler?(myTextView.text)
        cancelPressed()
    }
}

//
//  CheckList+Action.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 01/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import  UIKit
import PKHUD

extension RequirementsViewController {
    @IBAction func rightPressed(sender: UIButton) {
        if let index = collectionView.indexPathsForVisibleItems.first?.item, index < (requirements.count) - 1 {
            sender.isEnabled = false
            collectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: true)
            delay(0.3) { [weak self] in
                self?.configureBottomView()
                sender.isEnabled = true
            }
        }
//        saveLocaly()
    }
    
    @IBAction func leftPressed(sender: UIButton) {
        if let index = collectionView.indexPathsForVisibleItems.first?.item, index > 0 {
            sender.isEnabled = false
            collectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: true)
            delay(0.3) { [weak self] in
                self?.configureBottomView()
                sender.isEnabled = true
            }
        }
//        saveLocaly()
    }
    
    @objc func sendToServerTouched() {
        guard let request = getRequestForRequirementSave() else {
            return
        }
        saveLocaly(request: request)
        
        if api.isConnectedToInternet() {
            HUD.show(.progress)
            interactor?.setRequirement(request: request) { [weak self] serverRequirement in
                if let serverRequirement = serverRequirement {
                    self?.uploadPhotosFor(requir: serverRequirement, cb: { success in
                        if success {
                            presentAlert(title: "Данные отправлены на сервер", text: "")
                        } else {
                            presentAlert(title: "Не удалось отправить фотографии на сервер", text: "")
                        }
                        self?.interactor?.reloadFromDB()
                        HUD.hide()
                    })
                } else {
                    HUD.hide()
                }
            }
        } else {
            presentAlert(title: "Данные сохранены локально", text: "Когда появится выход в интернет, нажмите эту кнопку еще раз, чтобы отправить данные на сервер")
        }

    }
    
    
    
    func saveLocaly(request: Requirements.SetRequirement.Request? = nil) {
        if let request = request ?? getRequestForRequirementSave() {
            RequirementModel.saveLocalRequirFor(checkListId: interactor!.checkListId,
                                                title: request.requirementText,
                                                note: request.note ?? "",
                                                yesNo: request.yesNo)
        }
    }
    
    
    
    fileprivate func getRequestForRequirementSave() -> Requirements.SetRequirement.Request? {
        guard let ip = collectionView.indexPathsForVisibleItems.first, let cell = collectionView.visibleCells.first as? ItemCell else {
            assert(false)
            return nil
        }
        print("!!!!!", ip.row)
        let yesOrNo = cell.segmentedControl.selectedSegmentIndex
        guard yesOrNo == 0 || yesOrNo == 1  else {
            presentAlert(title: "Вначале выберите Да или Нет", text: "")
            return nil
        }
        
        let requirement = requirements[ip.row]
        let request = Requirements.SetRequirement.Request(requirementId: requirement.id,
                                                          requirementText: cell.textLabel.text,
                                                          yesNo: yesOrNo == 0,
                                                          note: cell.commentLabel.text)
        return request
    }
    
    
    
    fileprivate func uploadPhotosFor(requir: RequirementModel, cb: @escaping (Bool) -> Void) {
        if let photos: [Photo] = requir.photos?.toArray(), !photos.isEmpty {
            
            let gr = DispatchGroup()
            for photo in photos {
                if photo.isUploaded {
                    continue
                }
                let action = API.Action.setPhotoForRequiremenrt(id: requir.id!, photoData: photo.data!)
                
                gr.enter()
                api.setPhotoForRequiremenrt(action: action, cb: { (result) in
                    switch result {
                    case .Success:
                        Log("Отправили фото на сервер", type: .info)
                    case .Failure(let error):
                        Log(error.localizedDescription, type: .error)
                    }
                    gr.leave()
                })
            }
            gr.notify(queue: .main) {
                cb(true)
            }
            
        } else {
            cb(true)
        }

    }
    
    
    func didEndScroll() {
        configureBottomView()
    }
}

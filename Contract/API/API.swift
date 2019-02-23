//
//  API.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 24/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import SWXMLHash

var api: APIProtocol!


extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone? = nil) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone ?? TimeZone(abbreviation: "UTC")!
    }
}

extension Formatter {
    struct Date {
        static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
    }
}

//let date = Date()
//let formatter = ISO8601DateFormatter()
//formatter.formatOptions.insert(.withFractionalSeconds)  // this is only available effective iOS 11 and macOS 10.13
//print(formatter.string(from: date))

protocol APIProtocol {
    func login(action: API.Action, cb: @escaping (Result<(user: User, token: String)>) -> Void)
    func getTemplates(action: API.Action, cb: @escaping (Result<[TemplateModel]>) -> Void)
    func getMyCheckLists(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void)
    func createCheckListFromTemplate(action: API.Action, cb: @escaping (Result<String>) -> Void)
    func removeCheckList(action: API.Action, cb: @escaping (Result<Void>) -> Void)
    
    func getTemplateRequirementsFor(action: API.Action, cb: @escaping (Result<[RequirementTemplate]>) -> Void)

    func getRequirementsForCheckList(action: API.Action, cb: @escaping (Result<[RequirementModel]>) -> Void)
    
    /// создать новое требование
    /// - Returns: возвращает локальное требование
    func setRequirement(action: API.Action, cb: @escaping (Result<RequirementModel>) -> Void)
    func deleteRequirement(action: API.Action, cb: @escaping (Result<Bool>) -> Void)
    
    func getPhotoDataByLink(action: API.Action, cb: @escaping (Result<String>) -> Void)
    func deletePhoto(action: API.Action, cb: @escaping (Result<String>) -> Void)
    func getPhotoLinksForRequirement(action: API.Action, cb: @escaping (Result<Bool>) -> Void)
    func setPhotoForRequiremenrt(action: API.Action, cb: @escaping (Result<Photo>) -> Void)
    func deleteAllPhotosForRequirement(action: API.Action, cb: @escaping (Result<Bool>) -> Void)
    

}

class API: APIProtocol {
    
    let serviceURL = "http://195.128.127.188:54321/SmartService/Service1.svc"
    init() {
        api = self
    }
    
    fileprivate lazy var reachability: NetworkReachability = NetworkReachability(hostname: serviceURL)

    
//    enum ProccesingMode {
//        case saveLocal
//    }
//
//    enum CacheType {
//        case localElseNetwork
//        case localThenNetwork
//        case local
//        case network
//    }
    
    func isConnectedToInternet() -> Bool {
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            return false
        case .reachableViaWiFi, .reachableViaWWAN:
            return true
        }
    }
    func login(action: API.Action, cb: @escaping (Result<(user: User, token: String)>) -> Void) {
        switch action {
        case .getSession:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    let token = result["a:GUID"].element!.text
                    print("token: ", token)
                    let user = User.saveUser(xml: result)
                    cb(Result.Success(data: (user: user, token: token)))
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func getTemplates(action: API.Action, cb: @escaping (Result<[TemplateModel]>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        
        switch action {
        case .getTemplates:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    let array = result["a:checkList_"]
                    let serverTemplates = TemplateModel.saveObjects(xmlObjects: array.all)
                    cb(Result.Success(data: serverTemplates))
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    

    
    func createCheckListFromTemplate(action: API.Action, cb: @escaping (Result<String>) -> Void) {
        switch action {
        case .createCheckListFromTemplate:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    if let id = result.element?.text {
                        cb(Result.Success(data: id))
                    } else {
                        cb(Result.Failure(error: CustomError.CannotFetch("Ошибка")))
                    }
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    

    func getMyCheckLists(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void) {
        switch action {
        case .getMyChecklists:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    let array = result["a:checkList_"]
                    let obj = CheckListModel.saveObjects(xmlObjects: array.all)
                    cb(Result.Success(data: obj))
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func removeCheckList(action: API.Action, cb: @escaping (Result<Void>) -> Void) {
        switch action {
        case .deleteCheckList:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    if result.element?.text == "deleted" {
                        cb(Result.Success(data: ()))
                    } else {
                        cb(Result.Failure(error: CustomError.CannotDelete("Не удалось удалить")))
                    }
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func getTemplateRequirementsFor(action: API.Action, cb: @escaping (Result<[RequirementTemplate]>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .getTemplateRequirementsFor(let templateCheckListId):
//            Log("getting requir templates for checklistId: \(templateCheckListId)", type: .info)
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    let array = result["a:requirementsTemplate"]
//                    print("requir template count: ", array.all.count, "checklistId: ", templateCheckListId)
                    let templates = RequirementTemplate.saveObjects(checkListId: templateCheckListId, xmlObjects: array.all)
                    cb(Result.Success(data: templates))
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func getRequirementsForCheckList(action: API.Action, cb: @escaping (Result<[RequirementModel]>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .getRequirementsForMy(let checkListId):
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    let array = result["a:requirements"]
                    let requirModels = RequirementModel.saveServerRequirements(checkListId: checkListId, xmlObjects: array.all)
                    cb(Result.Success(data: requirModels))
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    
    func setRequirement(action: API.Action, cb: @escaping (Result<RequirementModel>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .setRequirement(let checkListId, let requirementText, let yesNo, let note):
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let res):
                    let requirementId = res.element!.text
                    Log("Got server requirement id: \(requirementId)", type: .info)
                    let requirementModel = RequirementModel.saveRequirement(checkListId: checkListId,
                                                                            requirementId: requirementId,
                                                                            note: note,
                                                                            yesNo: yesNo,
                                                                            text: requirementText)
                    if let requirementModel = requirementModel {
                        cb(Result.Success(data: requirementModel))
                    } else {
                        cb(Result.Failure(error: CustomError.CannotCreate("Не удалось создать локальную модель RequirementModel")))
                    }
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func deleteRequirement(action: API.Action, cb: @escaping (Result<Bool>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .deleteRequirement(let requirementId):
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let res):
                    let deleted = res.element!.text
                    Log("Requirement \(requirementId) deleted from server", type: .info)
                    
//                    if let requirementModel = requirementModel {
                        cb(Result.Success(data: true))
//                    } else {
//                        cb(Result.Failure(error: CustomError.CannotCreate("Не удалось удалить требование с сервера")))
//                    }
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func getPhotoDataByLink(action: API.Action, cb: @escaping (Result<String>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .getPhotoDataByLink:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    //                    let array = result["a:requirementsTemplate"]
                    //                    let templates = RequirementTemplate.saveObjects(checkListId: templateCheckListId, xmlObjects: array.all)
                    //                    cb(Result.Success(data: templates))
                    break
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func deletePhoto(action: API.Action, cb: @escaping (Result<String>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .deletePhoto:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    print(result)
                    //                    let array = result["a:requirementsTemplate"]
                    //                    let templates = RequirementTemplate.saveObjects(checkListId: templateCheckListId, xmlObjects: array.all)
                    //                    cb(Result.Success(data: templates))
                    break
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func getPhotoLinksForRequirement(action: API.Action, cb: @escaping (Result<Bool>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .getPhotoLinksForRequirement(let reqId):
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    print(result)
                    let array = result.all
                    Photo.saveServerPhotos(xmlObjects: array, reqId: reqId)
                    cb(Result.Success(data: true))
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func setPhotoForRequiremenrt(action: API.Action, cb: @escaping (Result<Photo>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .setPhotoForRequiremenrt(let requirementId, let photoData):
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    let photoId = result.element!.text
                    if let photo = Photo.savePhoto(id: photoId, data: photoData, requirementId: requirementId) {
                        cb(Result.Success(data: photo))
                    } else {
                         cb(Result.Failure(error: CustomError.CannotCreate("Не удалось сохранить фото")))
                    }
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotCreate(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
    
    func deleteAllPhotosForRequirement(action: API.Action, cb: @escaping (Result<Bool>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .deleteAllPhotosForRequirement(let reqId):
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    let text = result.element?.text
                    if let text = text, text == "Incorrect syntax near \'*\'." {
                        cb(Result.Failure(error: CustomError.CannotDelete(text)))
                    } else {
                        Photo.removeAllPhotosFor(requirementId: reqId)
                    }
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
            break
        }
    }
}

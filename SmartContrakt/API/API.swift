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
    func getObjects(action: API.Action, cb: @escaping (Result<[ObjectModel]>) -> Void)
    func getCheckList(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void)
    func createCheckListFromTemplate(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void)
    func setCheckListItem(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void)
}

class API: APIProtocol {
    
    init() {
        api = self
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
    
    func getObjects(action: API.Action, cb: @escaping (Result<[ObjectModel]>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .getTemplates:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    let array = result["a:checkList"]
                    let obj = ObjectModel.saveObjects(xmlObjects: array.all)
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
    
    func getCheckList(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .getRequirementsFor:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    let array = result["a:требования"]
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
    
    func createCheckListFromTemplate(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void) {
        switch action {
        case .createCheckListFromTemplate:
            checkGuidAndSendRequest(with: action) { result in
                switch result {
                case .Success(let result):
                    print(result)
                    let array = result["a:требования"]
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
    
    func setCheckListItem(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void) {
        
    }
}

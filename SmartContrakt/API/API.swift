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


protocol APIProtocol {
    func login(action: API.Action, cb: @escaping (Result<(user: User, token: String)>) -> Void)
    func getObjects(action: API.Action, cb: @escaping (Result<[ObjectModel]>) -> Void)
    func getCheckList(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void)
}

class API: APIProtocol {
    
    init() {
        api = self
    }
    
    enum Action {
        case getSession(logn: String, pass: String)
        case getObjects
        case getCheckList(objectId: String)
        
        var description: String {
            get {
                switch self {
                case .getSession:
                    return "GetSession"
                case .getObjects:
                    return "GetCheckList"
                case .getCheckList:
                    return "GetCheckListDetail"
                }
            }
        }
        
        var envelope: String {
            get {
                switch self {
                case .getSession(let login, let pass):
                    return """
                    <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
                    <s:Body>
                    <\(description) xmlns="http://tempuri.org/">
                    <login>\(login)</login>
                    <pass>\(pass)</pass>
                    </\(description)>
                    </s:Body>
                    </s:Envelope>
                    """
                case .getObjects:
                    return """
                    <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
                    <s:Body>
                    <\(description) xmlns="http://tempuri.org/">
                    <guid>\(CurrentUser.getToken()!)</guid>
                    </\(description)>
                    </s:Body>
                    </s:Envelope>
                    """
                case .getCheckList(let objectId):
                    return """
                    <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
                    <s:Body>
                    <\(description) xmlns="http://tempuri.org/">
                    <guid>\(CurrentUser.getToken()!)</guid>
                    <id_checkList>\(objectId)</id_checkList>
                    </\(description)>
                    </s:Body>
                    </s:Envelope>
                    """
                }
            }
        }
    }
    

    func login(action: API.Action, cb: @escaping (Result<(user: User, token: String)>) -> Void) {
        switch action {
        case .getSession:
            makeRequest(with: action.description, env: action.envelope) { [unowned self] result in
                switch result {
                case .Success(let data):
                    let xml = self.getXML(for: data)
                    let result = xml["GetSessionResponse"]["GetSessionResult"]
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
        }
    }
    
    func getObjects(action: API.Action, cb: @escaping (Result<[ObjectModel]>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .getObjects:
            makeRequest(with: action.description, env: action.envelope) { [unowned self] result in
                switch result {
                case .Success(let data):
                    let xml = self.getXML(for: data)
                    let result = xml["GetCheckListResponse"]["GetCheckListResult"]
                    let array = result["a:список_чек_листов"]
                    let obj = ObjectModel.saveObjects(xmlObjects: array.all)
                    cb(Result.Success(data: obj))
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
        }
    }
    
    func getCheckList(action: API.Action, cb: @escaping (Result<[CheckListModel]>) -> Void) {
        guard let _ = CurrentUser.getToken() else {
            cb(Result.Failure(error: CustomError.CannotFetch("Токен не обнаружен")))
            return
        }
        switch action {
        case .getCheckList:
            makeRequest(with: action.description, env: action.envelope) { [unowned self] result in
                switch result {
                case .Success(let data):
                    let xml = self.getXML(for: data)
                    let result = xml["GetCheckListDetailResponse"]["GetCheckListDetailResult"]
                    let array = result["a:требования"]
                    let obj = CheckListModel.saveObjects(xmlObjects: array.all)
                    cb(Result.Success(data: obj))
                case .Failure(let error):
                    cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
                }
            }
        default:
            assert(false)
        }
    }
}

//
//  API.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 24/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

enum Result<U>
{
    case Success(data: U)
    case Failure(error: CustomError)
}

// MARK: - Publications store CRUD operation errors

enum CustomError: Equatable, Error
{
    case CannotFetch(String)
    case CannotCreate(String)
    case CannotUpdate(String)
    case CannotDelete(String)
    
    var localizedDescription: String {
        switch self {
        case .CannotFetch(let error):
            return error
        case .CannotCreate(let error):
            return error
        case .CannotUpdate(let error):
            return error
        case .CannotDelete(let error):
            return error
        }
    }
}

let api = API()



class API {
    
    enum Action {
        case getSession
        
        var description: String {
            get {
                switch self {
                case .getSession:
                    return "GetSession"
                }
            }
        }
    }
    

    
    
    func login(name: String, password: String, cb: @escaping (Result<User>) -> Void) {
         let loginRequest = """
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
            <s:Body>
            <GetSession xmlns="http://tempuri.org/">
            <login>\(name)</login>
            <pass>\(password)</pass>
            </GetSession>
            </s:Body>
            </s:Envelope>
"""
        makeRequest(with: .getSession, env: loginRequest) { result in
            switch result {
            case .Success(let data):
                let xml = api.getXML(for: data)
                let result = xml["GetSessionResponse"]["GetSessionResult"]
                let token = result["a:GUID"].element!.text
                print("token: ", token)
                let user = User.saveUser(xml: result)
                cb(Result.Success(data: user))
            case .Failure(let error):
                cb(Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
            }
        }
    }
    
    
    
    private func getXML(for data: Data) -> XMLIndexer {
        return SWXMLHash.parse(data)["s:Envelope"]["s:Body"]
    }
    
    
    private func makeRequest(with action: Action, env: String, cb: @escaping (Result<Data>) -> Void) {
        
        func returnOnMainQueue(res: Result<Data>) {
            DispatchQueue.main.async {
                cb(res)
            }
        }
        
        let headers = [
            "SOAPAction": "http://tempuri.org/IService1/\(action.description)",
            "Content-Type": "text/xml"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: "http://195.128.127.188:54321/SmartService/Service1.svc")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 60.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = env.data(using: .utf8)
        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data, data.count > 0 {
                returnOnMainQueue(res: Result.Success(data: data))
                
            } else if let error = error {
                returnOnMainQueue(res: Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
            } else {
                returnOnMainQueue(res: Result.Failure(error: CustomError.CannotFetch("Неопознанная ошибка \(response?.description ?? "")")))
            }
        }
        dataTask.resume()
    }
    
}
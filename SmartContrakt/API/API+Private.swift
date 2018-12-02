//
//  API+Private.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 27/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation
import SWXMLHash

extension API {

    private func checkGUID(action: API.Action, cb: @escaping (Result<XMLIndexer>) -> Void, guidIsGoodCallback: @escaping () -> ()) {
        switch action {
        case .checkGUID:
            sendRequestToServer(with: action) { result in
                switch result {
                case .Success(let result):
                    let isGood = result.element?.text
                    if isGood == "1" {
                        guidIsGoodCallback()
                    } else {
                        cb(Result.Failure(error: CustomError.CannotFetch("GUID is not valid")))
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
    
    func checkGuidAndSendRequest(with action: API.Action, cb: @escaping (Result<XMLIndexer>) -> Void) {
        if action.mustCheckGuid {
            checkGUID(action: API.Action.checkGUID, cb: cb) { [unowned self] in
                self.sendRequestToServer(with: action, cb: cb)
            }
        } else {
            self.sendRequestToServer(with: action, cb: cb)
        }
    }
    
    private func sendRequestToServer(with action: API.Action, cb: @escaping (Result<XMLIndexer>) -> Void) {

        func returnOnMainQueue(res: Result<XMLIndexer>) {
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
        request.httpBody = action.envelope.data(using: .utf8)
        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data, data.count > 0 {
                let xml = SWXMLHash.parse(data)["s:Envelope"]["s:Body"]
                let result = xml["\(action.description)Response"]["\(action.description)Result"]
                returnOnMainQueue(res: Result.Success(data: result))
                
            } else if let error = error {
                returnOnMainQueue(res: Result.Failure(error: CustomError.CannotFetch(error.localizedDescription)))
            } else {
                returnOnMainQueue(res: Result.Failure(error: CustomError.CannotFetch("Неопознанная ошибка \(response?.description ?? "")")))
            }
        }
        dataTask.resume()
    }
    
    
}

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
    
    
    func getXML(for data: Data) -> XMLIndexer {
        return SWXMLHash.parse(data)["s:Envelope"]["s:Body"]
    }
    
    
    func makeRequest(with action: String, env: String, cb: @escaping (Result<Data>) -> Void) {
        
        func returnOnMainQueue(res: Result<Data>) {
            DispatchQueue.main.async {
                cb(res)
            }
        }
        
        let headers = [
            "SOAPAction": "http://tempuri.org/IService1/\(action)",
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

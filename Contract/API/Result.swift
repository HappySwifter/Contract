//
//  CustomError.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 27/11/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation

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
    case NoNetwork
    case badGUID
    
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
        case .NoNetwork:
            return "Проверьте подключение к интернету"
        case .badGUID:
            return "Сессия прервана. Войдите в систему заново"
            
        }
    }
}

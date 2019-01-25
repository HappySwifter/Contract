
//
//  API+Actions.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 03/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation

extension API {
    
    enum Action {
        /// возвращает данные о юзере + guid
        case getSession(logn: String, pass: String)
        /// проверяет guid на валидность
        case checkGUID
        
        /// получить список шаблонов
        case getTemplates
        
        /// создать чеклист из шаблона. возвращается новый id_checkList
        case createCheckListFromTemplate(requisit: String, title: String, date: String)
        /// получить список чеклистов, которые были созданы мною
        case getMyChecklists
        /// удалить чеклист. возвращается "deleted"
        case deleteCheckList(checkListId: String)
        
        /// получить шаблонные пункты чеклиста
        case getTemplateRequirementsFor(templateCheckListId: String)
        /// получить список требований, которые я сохранял для данного чеклиста
        case getRequirementsForMy(checkListId: String)
        /// требование сохраняется, возвращается id_requirement созданный
        case setRequirement(checkListId: String, requirementText: String, yesNo: Bool, note: String)
        
        
        /// возвращается массив <byte[]>
        case getPhotoDataByLink(link: String)
        /// удалить фото
        case deletePhoto(link: String)
        /// возвращается массив <LinkPhoto>
        case getPhotoLinksForRequirement(id: String)
        /// фото сохраняется, возвращается LinkPhoto
        case setPhotoForRequiremenrt(id: String, photoData: String)
        /// Удалить все фото для требования
        case deleteAllPhotosForRequirement(id: String)
        
        var description: String {
            get {
                switch self {
                case .getSession:
                    return "GetSession"
                case .checkGUID:
                    return "CheckGuid"
                case .getTemplates:
                    return "GetCheckListTemplate"
                case .createCheckListFromTemplate:
                    return "SetCheckList"
                case .getTemplateRequirementsFor:
                    return "GetRequirementsTemplate"
                case .deleteCheckList:
                    return "DeleteCheckList"
                case .setRequirement:
                    return "SetRequirement"
                case .getMyChecklists:
                    return "GetCheckList"
                case .getRequirementsForMy:
                    return "GetRequirements"
                    
                case .getPhotoDataByLink:
                    return "GetPhotoFromLink"
                case .deletePhoto:
                    return "DeletePhotoFromLink"
                case .getPhotoLinksForRequirement:
                    return "GetAllPhotoInRequirement"
                case .setPhotoForRequiremenrt:
                    return "SetPhoto"
                case .deleteAllPhotosForRequirement:
                    return "DeleteAllPhotoInRequirement"
                }
            }
        }
        
        var envelope: String {
            get {
                switch self {
                case .getSession(let login, let pass):
                    let params = """
                    <login>\(login)</login>
                    <pass>\(pass)</pass>
                    """
                    return insertParamsToEnvelope(params: params, withToken: false)
                case .checkGUID:
                    return insertParamsToEnvelope(params: "", withToken: true)
                case .getTemplates:
                    return insertParamsToEnvelope(params: "", withToken: true)
                case .createCheckListFromTemplate(let reqisit, let title, let dateString):
                    let params = """
                    <title>\(title)</title>
                    <requisites>\(reqisit)</requisites>
                    <dateTime>\(dateString)</dateTime>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                case .getTemplateRequirementsFor(let templateCheckListId):
                    let params = """
                    <id_checkList>\(templateCheckListId)</id_checkList>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                case .deleteCheckList(let checkListId):
                    let params = """
                    <id_checkList>\(checkListId)</id_checkList>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                case .setRequirement(let checkListId, let requirementText, let yesNo, let note):
                    let yesNoString = yesNo ? "1" : "0"
                    let params = """
                    <id_checkList>\(checkListId)</id_checkList>
                    <requirement>\(requirementText)</requirement>
                    <availability>\(yesNoString)</availability>
                    <note>\(note)</note>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                case .getMyChecklists:
                    return insertParamsToEnvelope(params: "", withToken: true)
                case .getRequirementsForMy(let checkListId):
                    let params = """
                    <id_checkList>\(checkListId)</id_checkList>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                    
                    
                case .setPhotoForRequiremenrt(let requirementId, let photoData):
                    let params = """
                    <id_requirement>\(requirementId)</id_requirement>
                    <photo>\(photoData)</photo>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                case .getPhotoLinksForRequirement(let requirementId):
                    let params = """
                    <id_requirement>\(requirementId)</id_requirement>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                case .deletePhoto(let link):
                    let params = """
                    <linkPhoto>\(link)</linkPhoto>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                case .getPhotoDataByLink(let link):
                    let params = """
                    <linkPhoto>\(link)</linkPhoto>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                case .deleteAllPhotosForRequirement(let requirementId):
                    let params = """
                    <id_requirement>\(requirementId)</id_requirement>
                    """
                    return insertParamsToEnvelope(params: params, withToken: true)
                }
            }
        }
        
        var mustCheckGuid: Bool {
            get {
                switch self {
                case .checkGUID, .getSession:
                    return false
                default:
                    return true
                }
            }
        }
        
        
        func insertParamsToEnvelope(params: String, withToken: Bool) -> String {
            let begining = """
            <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
            <s:Body>
            <\(description) xmlns="http://tempuri.org/">
            """
            
            let end = """
            </\(description)>
            </s:Body>
            </s:Envelope>
            """
            
            if withToken {
                let tokenParam = "<guid>\(CurrentUser.getToken()!)</guid>"
                return begining + tokenParam + params + end
            } else {
                return begining + params + end
            }
        }
    }
}

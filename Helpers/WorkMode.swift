//
//  WorkMode.swift
//  SmartContrakt
//
//  Created by Артем Валиев on 03/12/2018.
//  Copyright © 2018 Артем Валиев. All rights reserved.
//

import Foundation

enum WorkMode: Int {

    case online = 0
    case offline = 1
    
    static func getMode() -> WorkMode {
        let def = UserDefaults.standard
        let mode = def.integer(forKey: "current_work_mode")
        return WorkMode.init(rawValue: mode) ?? .online
    }
    

    static func save(mode: WorkMode) {
        let def = UserDefaults.standard
        def.set(mode.rawValue, forKey: "current_work_mode")
        def.synchronize()
    }
    
}

//
//  Log.swift
//  Machine
//
//  Created by Артем Валиев on 29/07/2017.
//  Copyright © 2017 Артем Валиев. All rights reserved.
//

import Foundation

enum LogType {
    case info, error, warning
}

func Log(_ message: String = "", type: LogType = .info, filename: String = #file, function: String = #function, line: Int = #line) {
    let fileName = (filename as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "", options: .caseInsensitive , range: nil)
    switch type {
    case .info:
        print("[\(fileName): \(line) -> \(function)]  \(message)")
    case .warning:
        print("👉 [\(fileName): \(line) -> \(function)]  \(message)")
    case .error:
        print("😡 [\(fileName): \(line) -> \(function)]  \(message)")
    }
}

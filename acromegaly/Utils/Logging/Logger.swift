//
//  Logger.swift
//  PlayNow
//
//  Created by Kuba on 09/07/2018.
//  Copyright © 2018 N7 Mobile Sp. z o.o. All rights reserved.
//

import Foundation

enum LogLevel: String {
    case debug = "💚"
    case warning = "🧡"
    case error = "❤️"
}

final class Logger {
    
    private static let instance = Logger()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    static func debug(_ message: String, _ file: String = #file) {
        instance.log(.debug, message, file)
    }
    
    static func warning(_ message: String, _ file: String = #file) {
        instance.log(.warning, message, file)
    }
    
    static func error(_ message: String, _ file: String = #file) {
        instance.log(.error, message, file)
    }
    
    private init() {}
    
    private func log(_ level: LogLevel, _ message: String, _ file: String = #file) {
        let timestamp = self.dateFormatter.string(from: Date())
        print("\(level.rawValue) \(timestamp) \(self.fileName(fromPath: file)): \(message)")
    }
    
    private func fileName(fromPath path: String) -> String {
        return path.components(separatedBy: "/").last ?? ""
    }
}

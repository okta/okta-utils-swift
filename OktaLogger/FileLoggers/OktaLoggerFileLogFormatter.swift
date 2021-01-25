//
//  OktaLoggerFileLogFormatter.swift
//  OktaLogger
//
//  Created by Borys Kasianenko on 1/25/21.
//

import Foundation
import CocoaLumberjack

@objc
class OktaLoggerFileLogFormatter: NSObject, DDLogFormatter {

    private let dateFormatter: DateFormatter

    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS Z"
        super.init()
    }

    func format(message logMessage: DDLogMessage) -> String? {
        let timestamp = dateFormatter.string(from: logMessage.timestamp)
        return "\(timestamp) \(logMessage.message)"
    }
}

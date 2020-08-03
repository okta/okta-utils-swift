//
//  OktaLoggerFileLoggerConfig.swift
//  OktaLogger
//
//  Created by Kaushik Krishnakumar on 7/17/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import Foundation
@objc
public class OktaLoggerFileLoggerConfig: NSObject {

    public enum Engine {
        case CocoaLumberjack
    }

    /**
    File logging library to use
    */
    var engine = Engine.CocoaLumberjack

    /**
     Log Rolling frequency in Seconds
     `rollingFrequency`
     How often to roll the log file.
     The frequency is given as an `NSTimeInterval`, which is a double that specifies the interval in seconds.
     Once the log file gets to be this old, it is rolled.
     */
    var rollingFrequency: TimeInterval

    /**
     Log Folder
     */
    var logFolder: String = ""

    public init(rollingFrequency: TimeInterval) {
        self.rollingFrequency = rollingFrequency
    }

    public convenience init(rollingFrequency: TimeInterval, logFolder: String) {
        self.init(rollingFrequency: rollingFrequency)
        self.logFolder = logFolder
    }
}

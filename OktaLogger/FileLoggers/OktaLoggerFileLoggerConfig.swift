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
    File logging library to use.
    */
    var engine = Engine.CocoaLumberjack

    /**
     Log Rolling frequency in Seconds
     `rollingFrequency`
     How often to roll the log file.
     The frequency is given as an `NSTimeInterval`, which is a double that specifies the interval in seconds.
     Once the log file gets to be this old, it is rolled.
     Default value is 2 days.
     */
    public var rollingFrequency: TimeInterval = 48 * 60 * 60

    /**
     Custom path to log folder.
     Default value is `nil` (file logger default folder will be used).
     */
    public var logFolder: String?

    /**
     If set, file logger will reuse existing log file.
     If not - it will create new file for every session.
     Default value is `false`.
     */
    public var reuseLogFiles: Bool = false

    /**
     Maximum number of log files that could be saved on disk.
     Default value is `1`.
     */
    public var maximumNumberOfLogFiles: UInt = 1
}

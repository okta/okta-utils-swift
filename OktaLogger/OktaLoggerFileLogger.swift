//
//  OktaLoggerFileLogger.swift
//  OktaLogger
//
//  Created by Kaushik Krishnakumar on 7/9/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import Foundation
import CocoaLumberjack

@objc
public class OktaLoggerFileLogger : OktaLoggerDestinationBase {
    var fileLogger:DDFileLogger = DDFileLogger();
    var isLoggingActive:Bool = true;
    
    @objc
    override public init(identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable : Any]?) {
        super.init(identifier: identifier, level: level, defaultProperties: defaultProperties)
        self.setupLogger()
    }
    
    @objc
    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String, line: NSNumber, funcName: String) {
        
        let logMessage = self.stringValue(level: level,
                                          eventName: eventName,
                                          message: message,
                                          file: file, line: line, funcName: funcName)
        // translate log level into relevant console type level
        self.log(level: level, message:logMessage)
    }
    
    @objc
    public func stopLoggingAfter(hours:Int) {
        DDLog.remove(self.fileLogger);
    }
    
    @objc
    public func stopLogging() {
        self.isLoggingActive = false;
        DDLog.remove(self.fileLogger)
    }
    
    @objc
    public func resetLogging() {
        self.fileLogger = DDFileLogger()
        self.setupLogger()
    }
    
    /**
     Remove all Loggers during de allocate
     */
    deinit {
        DDLog.remove(self.fileLogger)
    }
    
    /**
     Configure Logger Parameters
     */
    func setupLogger() {
        let logExpiryDay:Double = 60*60*24
        let logExpiryDefault: Double = logExpiryDay * 2
        self.fileLogger.rollingFrequency = logExpiryDefault // 48 hours
        self.fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(self.fileLogger)
        Timer.scheduledTimer(withTimeInterval:logExpiryDefault , repeats: false) { timer in
            self.stopLogging()
            timer.invalidate()
        }
        self.isLoggingActive = true
    }
    
    /**
     Create a structured string out of the logging parameters and properties
     */
    func stringValue(level: OktaLoggerLogLevel, eventName: String, message: String?, file: String, line: NSNumber, funcName: String) -> String {
        let filename = file.split(separator: "/").last
        let logMessageIcon = OktaLoggerLogLevel.logMessageIcon(level: level)
        return "{\(logMessageIcon) \"\(eventName)\": {\"message\": \"\(message ?? "")\", \"location\": \"\(filename ?? ""):\(funcName):\(line)\"}}"
    }
    
    /**
     Translate OktaLoggerLogLevel into a console-friendly OSLogType value
     */
    func log(level: OktaLoggerLogLevel, message:String) {
        switch level {
        case .debug:
            return DDLogDebug(message);
        case .info, .uiEvent:
            return DDLogInfo(message)
        case .error:
            return DDLogError(message)
        case .warning:
            return DDLogWarn(message)
        default:
            return DDLogWarn(message)
        }
    }
}

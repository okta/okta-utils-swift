//
// Created by Kaushik Krishnakumar on 7/29/20.
// Copyright (c) 2020 Okta, Inc. All rights reserved.
//

import CocoaLumberjack

class LumberjackLoggerDelegate: FileLoggerDelegate {

    var fileLogger: DDFileLogger

    public init(_ logConfig: OktaLoggerFileLoggerConfig) {
        fileLogger = {
            guard let logFolder = logConfig.logFolder else {
                return DDFileLogger()
            }
            let logFileManager = DDLogFileManagerDefault(logsDirectory: logFolder)
            return DDFileLogger(logFileManager: logFileManager)
        }()
        fileLogger.rollingFrequency = logConfig.rollingFrequency
        fileLogger.doNotReuseLogFiles = !logConfig.reuseLogFiles
        fileLogger.logFileManager.maximumNumberOfLogFiles = logConfig.maximumNumberOfLogFiles
        fileLogger.logFormatter = OktaLoggerFileLogFormatter()
        DDLog.add(fileLogger)
    }

    /**
     Log files directory path
     */
    @objc
    func directoryPath() -> String? {
        let path: String? = self.fileLogger.currentLogFileInfo?.filePath
        return path
    }

    // MARK: Retrieve Logs

    /**
     Retrieves logs data. Each `Data` object contains data from one log file.
     Result array is sorted by file creation date in ascending order.
    */
    @objc
    func getLogs() -> [Data] {
        self.fileLogger.flush()
        return self.getLogPaths().compactMap { url in
            try? Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
        }
    }

    /**
     Retrieves log files URLs.
     Result array is sorted by file creation date in ascending order.
    */
    @objc
    func getLogPaths() -> [URL] {
        return fileLogger.logFileManager.sortedLogFileInfos
            .reversed()
            .map { URL(fileURLWithPath: $0.filePath) }
    }

    /**
     Retrieves log data asynchronously. Completion block is always executed in main queue
    */
    @objc
    func getLogs(completion: @escaping ([Data]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let logData = self.getLogs()
            DispatchQueue.main.async {
                completion(logData)
            }
        }
    }

    // MARK: Purge Logs

    @objc
    func logsCanBePurged() -> Bool {
        return true
    }

    @objc
    func purgeLogs() {
        if !logsCanBePurged() {
            return
        }
        self.fileLogger.flush()
        self.fileLogger.rollLogFile {
            for info in self.fileLogger.logFileManager.unsortedLogFileInfos {
                try? FileManager.default.removeItem(atPath: info.filePath)
            }
        }
    }

    // MARK: Write logs

    /**
     Translate log message into DDLog message
     */
    func log(_ level: OktaLoggerLogLevel, _ message: String) {
        switch level {
        case .debug:
            return DDLogDebug(message)
        case .info, .uiEvent:
            return DDLogInfo(message)
        case .error:
            return DDLogError(message)
        case .warning:
            return DDLogWarn(message)
        default:
            return DDLogInfo(message)
        }
    }

    /**
     Remove all Loggers during deallocate
     */
    deinit {
        DDLog.remove(self.fileLogger)
    }
}

/*
 * Copyright (c) 2020-Present, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

#if SWIFT_PACKAGE
import CocoaLumberjackSwift
import LoggerCore
#else
import CocoaLumberjack
#endif


class LumberjackLoggerDelegate: FileLoggerDelegate {

    var fileLogger: DDFileLogger

    public init(_ logConfig: OktaLoggerFileLoggerConfig) {
        fileLogger = {
            guard let logFolder = logConfig.logFolder else {
                return DDFileLogger()
            }
            guard let logFileName = logConfig.logFileName else {
                let logFileManager = DDLogFileManagerDefault(logsDirectory: logFolder)
                return DDFileLogger(logFileManager: logFileManager)
            }
            let logFileManager = DDLogFileManagerCustomName(logsDirectory: logFolder, fileName: logFileName)
            return DDFileLogger(logFileManager: logFileManager)
        }()
        fileLogger.rollingFrequency = logConfig.rollingFrequency
        fileLogger.doNotReuseLogFiles = !logConfig.reuseLogFiles
        fileLogger.logFileManager.maximumNumberOfLogFiles = logConfig.maximumNumberOfLogFiles
        fileLogger.logFormatter = OktaLoggerFileLogFormatter()
        if let maxFileSize = logConfig.maximumFileSize {
            fileLogger.maximumFileSize = maxFileSize
        }
        DDLog.add(fileLogger)
    }

    /**
     Log files directory path
     */
    @objc
    func directoryPath() -> String? {
        let path: String? = fileLogger.currentLogFileInfo?.filePath
        return path
    }

    // MARK: Retrieve Logs

    /**
     Retrieves logs data. Each `Data` object contains data from one log file.
     Result array is sorted by file creation date in ascending order.
    */
    @objc
    func getLogs() -> [Data] {
        fileLogger.flush()
        return getLogPaths().compactMap { url in
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
        fileLogger.flush()
        fileLogger.rollLogFile { [fileLogger] in
            for info in fileLogger.logFileManager.unsortedLogFileInfos {
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
        DDLog.remove(fileLogger)
    }
}

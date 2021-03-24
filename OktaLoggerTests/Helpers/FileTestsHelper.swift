//
//  FileTestsHelper.swift
//  OktaLoggerTests
//
//  Created by Borys Kasianenko on 3/25/21.
//  Copyright © 2021 Okta, Inc. All rights reserved.
//

import Foundation
@testable import OktaLogger

class FileTestsHelper {

    static func countLines(_ data: Data) -> Int {
        let logData = String(data: data as Data, encoding: .utf8)
        var lineCount: Int = 0
        logData?.enumerateLines { (_, _) in
            lineCount += 1
        }
        return lineCount
    }

    static func getPaths(testObject: LumberjackLoggerDelegate) -> [URL] {
        let logFileInfos = testObject.fileLogger.logFileManager.sortedLogFileInfos
        var logFilePathArray = [URL]()
        for logFileInfo in logFileInfos {
            if logFileInfo.isArchived {
                continue
            }
            let logFilePath = logFileInfo.filePath
            let fileURL = URL(fileURLWithPath: logFilePath)
            if let _ = try? Data(contentsOf: fileURL, options: Data.ReadingOptions.mappedIfSafe) {
                logFilePathArray.insert(fileURL, at: 0)
            }
        }
        return logFilePathArray
    }

    static var defaultFileConfig: OktaLoggerFileLoggerConfig {
        // New random folder is created for each config.
        // This helps us to avoid collision between different tests.
        let config = OktaLoggerFileLoggerConfig()
        config.logFolder = FileTestsHelper.testLogsFolder
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .path
        return config
    }

    static func cleanUpLogs() {
        try? FileManager.default.removeItem(at: FileTestsHelper.testLogsFolder)
    }

    static private var testLogsFolder: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("TestLogs", isDirectory: true)
    }
}

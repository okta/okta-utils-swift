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
import Foundation
@testable import OktaLogger
#if SWIFT_PACKAGE
import LoggerCore
@testable import FileLogger
#endif

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

    // swiftlint:disable force_unwrapping
    private static var testLogsFolder: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("TestLogs", isDirectory: true)
    }
}

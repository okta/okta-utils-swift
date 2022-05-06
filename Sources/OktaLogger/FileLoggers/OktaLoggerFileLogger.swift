/*
 * Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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
#if SWIFT_PACKAGE
import LoggerCore
#endif

@objc
public class OktaLoggerFileLogger: OktaLoggerDestinationBase {

    var delegate: FileLoggerDelegate

    // MARK: Intializing logger
    @objc
    public init(logConfig: OktaLoggerFileLoggerConfig, identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        delegate = LumberjackLoggerDelegate(logConfig)
        super.init(identifier: identifier, level: level, defaultProperties: defaultProperties)
    }

    @objc
    override public convenience init(identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        self.init(logConfig: OktaLoggerFileLoggerConfig(), identifier: identifier, level: level, defaultProperties: defaultProperties)
    }

    // MARK: Logging
    @objc
    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {
        let log = self.stringValue(level: level, eventName: eventName, message: message, file: file, line: line, funcName: funcName)
        delegate.log(level, log)
    }

    /**
     Log file path
     */
    @objc
    public func logDirectoryAbsolutePath() -> String? {
        return delegate.directoryPath()
    }

    // MARK: Retrieve Logs
    /**
     Retrieve logs in the current thread. This method could be time consuming,
     so it's not recommended to call it from the main thread.
     */
    @objc
    public func getLogs() -> [Data] {
        return delegate.getLogs()
    }

    // MARK: Retrieve log files' paths
    @objc
    public func getLogPaths() -> [URL] {
        return delegate.getLogPaths()
    }

    /**
     Retrieves log data asynchronously. Completion block is always executed in main queue
    */
    @objc
    public func getLogs(completion: @escaping ([Data]) -> Void) {
        // fetch logs
        delegate.getLogs(completion: completion)
    }

    // MARK: Purge Logs
    @objc
    override open func logsCanBePurged() -> Bool {
        return delegate.logsCanBePurged()
    }

    @objc
    override open func purgeLogs() {
        if !logsCanBePurged() {
            return
        }
        delegate.purgeLogs()
    }

    /**
     Translate log message  into DDLog message
     */
    func log(level: OktaLoggerLogLevel, message: String) {
       delegate.log(level, message)
    }
}

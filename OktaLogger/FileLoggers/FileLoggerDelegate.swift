//
// Created by Kaushik Krishnakumar on 7/29/20.
// Copyright (c) 2020 Okta, Inc. All rights reserved.
//

import Foundation

/**
 Okta File Logger delegate to support different file logger implementation.
*/
protocol FileLoggerDelegate: AnyObject {

    // MARK: Logging
    func log(_ level: OktaLoggerLogLevel, _ message: String)
    func directoryPath() -> String?

    // MARK: retrieval
    func getLogs() -> [Data]
    func getLogPaths() -> [URL]
    func getLogs(completion: @escaping ([Data]) -> Void)

    // MARK: purge
    func logsCanBePurged() -> Bool
    func purgeLogs()
}

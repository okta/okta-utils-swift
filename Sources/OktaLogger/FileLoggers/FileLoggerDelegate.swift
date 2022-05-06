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
#if SWIFT_PACKAGE
import LoggerCore
#endif
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

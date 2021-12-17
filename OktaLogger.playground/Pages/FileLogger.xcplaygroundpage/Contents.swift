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

import UIKit
import OktaLogger

var str = "Hello, playground"

//: ---
/*: ## Initialize logger */
let destination = OktaLoggerFileLogger(identifier: "hello.world", level: .all, defaultProperties: nil)

//: ---
/*: ## Add destination to Okta Logger */
let logger = OktaLogger(destinations: [destination])

logger.error(eventName: "event", message: str)
//: ---
/*: ## Useful Snippets */
/*: 1. Where is log file */
let path = destination.logDirectoryAbsolutePath()

print(path ?? "Path is Empty")
/*: 2. Print File Contents */
let logs = destination.getLogs()

print("# logs: \(logs.count)")
for log in logs {
    var lineCount = 0
    let logData = String(data: log as Data, encoding: .utf8)

    logData?.enumerateLines { (_, _) in
        lineCount += 1
    }
    //: how many lines in log ?
    print("total lines: \(lineCount) lines \n \(logData)")
    print(logData)
}
/*: 3. Reset Logs */
    destination.purgeLogs()
/*: - Note: You can see that there is  0 log files after purging.  */

let logs2 = destination.getLogs()

print("# logs: \(logs2.count)")
/*: Logs also get reinitialized and are available after next logging statement*/

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
import CocoaLumberjackSwift
#else
import CocoaLumberjack
#endif

@objc
class DDLogFileManagerCustomName: DDLogFileManagerDefault {
    var fileName: String

    init(logsDirectory: String, fileName: String) {
        self.fileName = fileName
        super.init(logsDirectory: logsDirectory)
    }

    override var newLogFileName: String {
        return fileName
    }

    override func isLogFile(withName fileName: String) -> Bool {
        return self.fileName == fileName
    }
}

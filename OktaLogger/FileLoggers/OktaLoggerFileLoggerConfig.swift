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

@objc
public class OktaLoggerFileLoggerConfig: NSObject {

    public enum Engine {
        case CocoaLumberjack
    }

    /**
    File logging library to use.
    */
    var engine = Engine.CocoaLumberjack

    /**
     Log Rolling frequency in Seconds
     `rollingFrequency`
     How often to roll the log file.
     The frequency is given as an `NSTimeInterval`, which is a double that specifies the interval in seconds.
     Once the log file gets to be this old, it is rolled.
     Default value is 2 days.
     */
    public var rollingFrequency: TimeInterval = 48 * 60 * 60

    /**
     Custom path to log folder.
     Default value is `nil` (file logger default folder will be used).
     */
    public var logFolder: String?

    /**
     Custom name for log file. Requires custom path to log folder.
     Name should include file extension
     Default value is `nil` (file logger default name will be used).
     */
    public var logFileName: String?

    /**
     If set, file logger will reuse existing log file.
     If not - it will create new file for every session.
     Default value is `false`.
     */
    public var reuseLogFiles: Bool = false

    /**
     Maximum number of log files that could be saved on disk.
     Default value is `1`.
     */
    public var maximumNumberOfLogFiles: UInt = 1

    /**
     Maximum allowed file size saved on disk in bytes.
     Default value is 1 MB.
     */
    public var maximumFileSize: UInt64?
}

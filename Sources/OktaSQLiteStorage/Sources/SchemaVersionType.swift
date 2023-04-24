/*
* Copyright (c) 2023, Okta, Inc. and/or its affiliates. All rights reserved.
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

/// - Description: Abstraction for version representation. Versions are represented by Integers. To maintain SemVer specification compliance, use `enum` with SemVer-compatible cases, while having underlying `Int` as a `rawType`. Supports Swift Ranges syntax. Versions order is determined by RawType value, not versions declaration order.
public protocol SchemaVersionType: CaseIterable, Comparable, RawRepresentable where RawValue == Int, AllCases.Index == Int {}

public extension SchemaVersionType {
    static func < (a: Self, b: Self) -> Bool {
        return a.rawValue < b.rawValue
    }

    func versionByRawValue(_ rawValue: Int) -> Self? {
        let allCases = Self.allCases.sorted()
        return allCases.first(where: { $0.rawValue == rawValue })
    }
}

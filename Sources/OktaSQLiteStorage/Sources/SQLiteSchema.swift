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
import GRDB

public struct SQLiteSchema {
    public let schemaType: SQLiteSchemaType
    public let version: any SchemaVersionType

    public init(schemaType: SQLiteSchemaType, version: any SchemaVersionType) {
        self.schemaType = schemaType
        self.version = version
    }
}

public enum SQLiteSchemaType {
    case rawSQLSchema(sql: String)
    case delegated(build: (Database, Int) throws -> Void)
}

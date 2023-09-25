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

/// The EventName typealias is an alias for `String`
public typealias Name = String

/// Properties typealias is an alias for an optional dictionary of `String` keys and `String` values.
public typealias Properties = [String: String]?

/// The Property struct contains two constant properties: key and value, both of which are of type String. The struct has an initializer that takes in two parameters, key and value, and assigns them to the struct's properties.
public struct Property: Hashable {
    // key is a constant property, initialized with the value passed to the struct's initializer
    public let key: String
    // value is a constant property, initialized with the value passed to the struct's initializer
    public let value: String

    // Initializer which assigns the passed in key and value to the properties of the struct
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public typealias ScenarioEvent = Event

public typealias ScenarioID = String

/// Event for the given provider
public struct Event: Hashable {

    // Name of the event
    public let name: Name

    // Initial properties on the event
    public var properties: [Property]

    // Display Name to appear on provider dashboard
    public var displayName: Name

    let startTime = Date()
    let id: String

    public init(name: Name, displayName: Name = "", properties: [Property] = []) {
        self.name = name
        self.properties = properties
        self.displayName = displayName
        self.id = UUID().uuidString
    }

    public init(scenarioID: ScenarioID, name: Name, displayName: Name = "", properties: [Property] = []) {
        self.name = name
        self.properties = properties
        self.displayName = displayName
        self.id = scenarioID
    }
}

func synced(_ lock: Any, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

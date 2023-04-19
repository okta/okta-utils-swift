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
import OktaAnalytics

class LogsBrowseViewController: UIViewController {

    var logs: String = ""

    @IBOutlet private weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = logs.isEmpty ? "Logs are empty" : logs
        OktaAnalytics.updateScenario(scenarioID) { $0?.send(Property(key: "LogsBrowseViewController.viewDidLoad", value: "4")) }
    }
}

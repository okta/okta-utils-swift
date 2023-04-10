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
import OktaAnalytics

protocol LoggerDemoViewControllerProtocol: AnyObject {
    func refreshUI()
    func browseFileLogs(_ logs: String)
}

class LoggerDemoViewController: UITableViewController, LoggerDemoViewControllerProtocol {

    private let viewModel = LoggerDemoViewModel()
    private var localLogs: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        OktaAnalytics.updateScenario("Application") { $0?.send(Property(key: "LoggerDemoViewController.viewDidLoad", value: "3")) }
    }

    func refreshUI() {
        tableView.reloadData()
    }

    func browseFileLogs(_ logs: String) {
        self.localLogs = logs
        performSegue(withIdentifier: "BrowseLocalLogs", sender: nil)
    }

    private func item(at indexPath: IndexPath) -> DemoListSection.Item {
        return viewModel.sections[indexPath.section].items[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoTableViewCell", for: indexPath) as! DemoTableViewCell
        cell.setup(with: item(at: indexPath))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        item(at: indexPath).onSelect()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "BrowseLocalLogs":
            OktaAnalytics.updateScenario("Application") { $0?.send(Property(key: "LoggerDemoViewController.BrowseLocalLogs", value: "3")) }
            (segue.destination as? LogsBrowseViewController)?.logs = self.localLogs
        default:
            break
        }
    }
}

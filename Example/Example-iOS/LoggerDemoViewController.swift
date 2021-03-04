//
//  LoggerDemoViewController.swift
//  OktaLoggerDemoApp
//
//  Created by Lihao Li on 6/5/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import UIKit
import OktaLogger

protocol LoggerDemoViewControllerProtocol: class {
    func refreshUI()
    func browseFileLogs(_ logs: String)
}

class LoggerDemoViewController: UITableViewController, LoggerDemoViewControllerProtocol {

    private let viewModel = LoggerDemoViewModel()
    private var localLogs: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
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
            (segue.destination as? LogsBrowseViewController)?.logs = self.localLogs
        default:
            break
        }
    }
}

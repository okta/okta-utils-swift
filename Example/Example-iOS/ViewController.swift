//
//  ViewController.swift
//  OktaLoggerDemoApp
//
//  Created by Lihao Li on 6/5/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import UIKit
import OktaLogger

class ViewController: UITableViewController {
    private let consoleLogCellTexts = ["Log debug message", "Log info message", "Log warning message", "Log UI event message", "Log error message"]
    private let logEventNames = ["test-debug", "test-info", "test-warning", "test-ui", "test-error"]
    private let logLevelCellTexts = ["off", "debug", "info", "warning", "uiEvent", "error", "all"]
    private let logLevels: [OktaLoggerLogLevel] = [.off, .debug, .info, .warning, .uiEvent, .error, .all]
    private var logLevelSelectedIndex = 6
    private let logLevelSection = 0
    private let consoleLogSection = 1
    private let crashSection = 2

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case logLevelSection:
            return logLevelCellTexts.count
        case consoleLogSection:
            return consoleLogCellTexts.count
        case crashSection:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case logLevelSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoggerLevelTableCell", for: indexPath)
            cell.textLabel?.text = logLevelCellTexts[indexPath.row]
            if logLevelSelectedIndex == indexPath.row {
                cell.textLabel?.textColor = UIColor.red
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
            return cell
        case consoleLogSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoggerLevelTableCell", for: indexPath)
            cell.textLabel?.text = consoleLogCellTexts[indexPath.row]
            return cell
        case crashSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoggerLevelTableCell", for: indexPath)
            cell.textLabel?.text = "Force a crash"
            cell.textLabel?.textColor = UIColor.red
            return cell
        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case logLevelSection:
            logLevelSelectedIndex = indexPath.row
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
            let console = OktaLoggerConsoleLogger(identifier: "com.okta.OktaLoggerDemoApp.logger", level: logLevels[logLevelSelectedIndex], defaultProperties: nil)
            OktaLogger.main = OktaLogger(destinations: [console])
        case consoleLogSection:
            switch indexPath.row {
            case 0:
                OktaLogger.main?.debug(eventName: logEventNames[indexPath.row], message: consoleLogCellTexts[indexPath.row])
            case 1:
                OktaLogger.main?.info(eventName: logEventNames[indexPath.row], message: consoleLogCellTexts[indexPath.row])
            case 2:
                OktaLogger.main?.warning(eventName: logEventNames[indexPath.row], message: consoleLogCellTexts[indexPath.row])
            case 3:
                OktaLogger.main?.uiEvent(eventName: logEventNames[indexPath.row], message: consoleLogCellTexts[indexPath.row])
            case 4:
                OktaLogger.main?.error(eventName: logEventNames[indexPath.row], message: consoleLogCellTexts[indexPath.row])
            default:
                break
            }
        case crashSection:
            fatalError("Test fatal error")
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case logLevelSection:
            return "Change log level"
        case consoleLogSection:
            return "Log Message"
        case crashSection:
            return "Crash analytics"
        default:
            return nil
        }
    }

}

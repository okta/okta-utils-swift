//
//  LoggerDemoViewModel.swift
//  OktaLoggerDemoApp
//
//  Created by Borys Kasianenko on 3/3/21.
//  Copyright © 2021 Okta, Inc. All rights reserved.
//

import Foundation
import OktaLogger
import FirebaseCrashlytics

struct DemoListSection {

    struct Item {
        let title: String
        let type: ItemType
        let onSelect: () -> Void
    }

    enum ItemType {
        case checkbox(isChecked: Bool)
        case disclosure
        case plain
    }

    let title: String
    let items: [Item]
}

class LoggerDemoViewModel {

    weak var view: LoggerDemoViewControllerProtocol?
    private (set) var sections: [DemoListSection] = [] {
        didSet {
            view?.refreshUI()
        }
    }

    private let logger = OktaLogger()
    private var currentLogLevel = OktaLoggerLogLevel.all

    init() {
        addConsoleDestination()
        addFirebaseDestination()
        addFileDestination()
        sections = buildListSections()
    }
}

private extension LoggerDemoViewModel {

    func showLocalLogs() {
        guard let fileLogger = fileLoggerDestination else {
            return
        }
        view?.browseFileLogs(fileLogger.getLogs().reduce("", {
            $0 + (String(data: $1, encoding: .utf8) ?? "")
        }))
    }

    func updateSections() {
        sections = buildListSections()
    }

    enum LoggerDestinationID: String {
        case console = "com.okta.loggerDemo.console"
        case firebase = "com.okta.loggerDemo.firebase"
        case file = "com.okta.loggerDemo.file"
    }
}

// MARK: - Managing destinations

private extension LoggerDemoViewModel {

    func addConsoleDestination() {
        logger.addDestination(
            OktaLoggerConsoleLogger(
                identifier: LoggerDestinationID.console.rawValue,
                level: currentLogLevel,
                defaultProperties: nil
            )
        )
    }

    func addFirebaseDestination() {
        logger.addDestination(
            OktaLoggerFirebaseCrashlyticsLogger(
                crashlytics: Crashlytics.crashlytics(),
                identifier: LoggerDestinationID.firebase.rawValue,
                level: currentLogLevel
            )
        )
    }

    func addFileDestination() {
        logger.addDestination(
            OktaLoggerFileLogger(
                identifier: LoggerDestinationID.file.rawValue,
                level: currentLogLevel,
                defaultProperties: nil
            )
        )
    }

    func isDestinationActive(_ id: LoggerDestinationID) -> Bool {
        return logger.destinations.keys.contains(where: { $0 == id.rawValue })
    }

    func toggleDestination(_ id: LoggerDestinationID) {
        if isDestinationActive(id) {
            logger.removeDestination(withIdentifier: id.rawValue)
        } else {
            switch id {
            case .console: addConsoleDestination()
            case .firebase: addFirebaseDestination()
            case .file: addFileDestination()
            }
        }
        updateSections()
    }

    func selectLogLevel(_ level: OktaLoggerLogLevel) {
        guard level != currentLogLevel else {
            return
        }
        currentLogLevel = level
        logger.setLogLevel(level: level, identifiers: [
            LoggerDestinationID.console.rawValue,
            LoggerDestinationID.firebase.rawValue,
            LoggerDestinationID.file.rawValue
        ])
    }

    var fileLoggerDestination: OktaLoggerFileLogger? {
        return logger.destinations[LoggerDestinationID.file.rawValue] as? OktaLoggerFileLogger
    }
}

// MARK: - Building list model

private extension LoggerDemoViewModel {

    func buildListSections() -> [DemoListSection] {
        var sections = [
            buildDestinationsSection(),
            buildLogLevelsSection(),
            buildTestLoggingSection()
        ]
        if let fileLogsSection = buildFileLogsSection() {
            sections.append(fileLogsSection)
        }
        return sections
    }

    func buildDestinationsSection() -> DemoListSection {
        let items: [DemoListSection.Item] = [
            .init(
                title: "Console",
                type: .checkbox(isChecked: isDestinationActive(.console)),
                onSelect: { self.toggleDestination(.console) }
            ),
            .init(
                title: "Firebase",
                type: .checkbox(isChecked: isDestinationActive(.firebase)),
                onSelect: { self.toggleDestination(.firebase) }
            ),
            .init(
                title: "File",
                type: .checkbox(isChecked: isDestinationActive(.file)),
                onSelect: { self.toggleDestination(.file) }
            )
        ]
        return .init(title: "Destinations", items: items)
    }

    func buildLogLevelsSection() -> DemoListSection {
        let source: [(String, OktaLoggerLogLevel)] = [
            ("all", .all),
            ("debug", .debug),
            ("info", .info),
            ("warning", .warning),
            ("uiEvent", .uiEvent),
            ("error", .error),
            ("off", .off),
        ]
        return .init(
            title: "Log level",
            items: source.map { rawItem in
                DemoListSection.Item(
                    title: rawItem.0,
                    type: .checkbox(isChecked: currentLogLevel == rawItem.1),
                    onSelect: {
                        self.selectLogLevel(rawItem.1)
                        self.updateSections()
                    }
                )
            }
        )
    }

    func buildTestLoggingSection() -> DemoListSection {
        return .init(
            title: "Log Message",
            items: [
                .init(title: "Log debug message", type: .plain, onSelect: { self.logger.debug(eventName: "test-debug", message: "Log debug message") }),
                .init(title: "Log info message", type: .plain, onSelect: { self.logger.info(eventName: "test-info", message: "Log debug message") }),
                .init(title: "Log warning message", type: .plain, onSelect: { self.logger.warning(eventName: "test-warning", message: "Log debug message") }),
                .init(title: "Log UI event message", type: .plain, onSelect: { self.logger.uiEvent(eventName: "test-ui", message: "Log debug message") }),
                .init(title: "Log error message", type: .plain, onSelect: { self.logger.error(eventName: "test-error", message: "Log debug message") }),
                .init(title: "Log NSError object", type: .plain, onSelect: {
                    let error = NSError(domain: "com.okta.OktaLoggerDemoApp.test", code: -1, userInfo: ["testData": "some value"])
                    self.logger.log(error: error)
                }),
                .init(title: "Force crash", type: .plain, onSelect: { fatalError("Force a crash") }),
            ]
        )
    }

    func buildFileLogsSection() -> DemoListSection? {
        guard isDestinationActive(.file) else {
            return nil
        }
        return .init(
            title: "Local logs",
            items: [
                .init(
                    title: "Review file logs",
                    type: .disclosure,
                    onSelect: showLocalLogs
                ),
                .init(
                    title: "Clear file logs",
                    type: .plain,
                    onSelect: { self.fileLoggerDestination?.purgeLogs() }
                )
            ]
        )
    }
}

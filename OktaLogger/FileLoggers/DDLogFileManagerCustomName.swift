//
//  DDLogFileManagerCustomName.swift
//  OktaLogger
//
// Created by Brenner Ryan on 4/30/21.
// Copyright (c) 2021 Okta, Inc. All rights reserved.
//

import Foundation
import CocoaLumberjack

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

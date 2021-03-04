//
//  LogsBrowseViewController.swift
//  OktaLoggerDemoApp
//
//  Created by Borys Kasianenko on 3/4/21.
//  Copyright © 2021 Okta, Inc. All rights reserved.
//

import UIKit

class LogsBrowseViewController: UIViewController {

    var logs: String = ""

    @IBOutlet private weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = logs.isEmpty ? "Logs are empty" : logs
    }
}

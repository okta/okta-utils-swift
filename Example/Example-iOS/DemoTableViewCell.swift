//
//  DemoTableViewCell.swift
//  OktaLoggerDemoApp
//
//  Created by Kaushik Krishnakumar on 7/14/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import UIKit

class DemoTableViewCell: UITableViewCell {

    func setup(with item: DemoListSection.Item) {
        textLabel?.text = item.title
        accessoryType = {
            switch item.type {
            case .checkbox(let isChecked):
                return isChecked ? .checkmark : .none
            case .disclosure:
                return .disclosureIndicator
            case .plain:
                return .none
            }
        }()
    }
}

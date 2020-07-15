//
//  HomeViewController.swift
//  OktaLoggerDemoApp
//
//  Created by Kaushik Krishnakumar on 7/14/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UITableViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.features.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureTableViewCell", for: indexPath) as? FeatureTableViewCell else {
            fatalError("Not a FeatureTableViewCell. Error rendering cell.")
        }
        cell.featureLabel.text=Constants.features[indexPath.row]
        return cell;
    }
}

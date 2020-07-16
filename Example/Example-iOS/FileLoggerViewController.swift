//
//  FileLoggerViewController.swift
//  OktaLoggerDemoApp
//
//  Created by Kaushik Krishnakumar on 7/16/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import UIKit
import OktaLogger

class FileLoggerViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    let pickerData = ["debug","info","warning","uiEvent","error"]
    var logger:OktaLogger!
    var destination:OktaLoggerFileLogger!
    
    @IBOutlet weak var logLevelPicker: LogLevelPicker!
    @IBOutlet weak var outputView: UITextView!
    
        
    required init?(coder: NSCoder) {
        self.logger = nil
        self.destination = nil
        super.init(coder: coder)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //columns
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //rows
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        destination = OktaLoggerFileLogger(identifier: "hello.world", level: .all, defaultProperties: nil)
        logger = OktaLogger(destinations: [destination])
    }
    
    func reloadLogOutput() -> String {
        // for demo purposes only. executed on ui queue
        outputView.text=""
        var output:String = ""
        let logs = destination.getLogs()
        for log in logs {
            guard let logData = String(data: log as Data, encoding: .utf8) else {
                continue
            }
            output.append(logData)
        }
        outputView.text += output
        return output
    }
    
    @IBAction func printDebugMessage(_ sender: Any) {
        logger.debug(eventName: "demo.debug", message: "Logging Event")
        reloadLogOutput()
    }
    @IBAction func printInfoMessage(_ sender: Any) {
        logger.info(eventName: "demo.info", message: "Logging Event")
    }
    
    @IBAction func printWarningMessage(_ sender: Any) {
        logger.warning(eventName: "demo.warning", message: "Logging Event")
    }
    
    @IBAction func printUIEventMessage(_ sender: Any) {
        logger.uiEvent(eventName: "demo.uievent", message: "Logging Event")
    }
    
    @IBAction func printErrorMessage(_ sender: Any) {
        logger.error(eventName: "demo.error", message: "Logging Event")
    }
    
    @IBAction func purgeLogs(_ sender: Any) {
        print(reloadLogOutput())
        destination.purgeLogs()
        reloadLogOutput()
    }
    
    @IBAction func emailLogs(_ sender: Any) {
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}



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
    let pickerData = ["off","error","warning","uiEvent", "info","debug","all"]
    var logger:OktaLogger!
    var destination:OktaLoggerFileLogger!
    
    @IBOutlet weak var logLevelPicker: LogLevelPicker!
    @IBOutlet weak var outputView: UITextView!
    
    
    required init?(coder: NSCoder) {
        destination = OktaLoggerFileLogger(identifier: "fileLogger", level: .off, defaultProperties: nil)
        logger = OktaLogger(destinations: [destination])
        super.init(coder: coder)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //columns
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //rows
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var level = OktaLoggerLogLevel.all
        switch(row) {
        case 0:
            level = .off
        case 1:
            level = .error
        case 2:
            level = .warning
        case 3:
            level = .uiEvent
        case 4:
            level = .info
        case 5:
            level = .debug
        default:
            level = .all
        }
        logger.setLogLevel(level: level, identifiers: ["fileLogger"])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup log level picker
        self.logLevelPicker.delegate = self
        self.logLevelPicker.dataSource = self
        logger.setLogLevel(level: .off, identifiers: ["fileLogger"])
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
        reloadLogOutput()
    }
    
    @IBAction func printWarningMessage(_ sender: Any) {
        logger.warning(eventName: "demo.warning", message: "Logging Event")
        reloadLogOutput()
    }
    
    @IBAction func printUIEventMessage(_ sender: Any) {
        logger.uiEvent(eventName: "demo.uievent", message: "Logging Event")
        reloadLogOutput()
    }
    
    @IBAction func printErrorMessage(_ sender: Any) {
        logger.error(eventName: "demo.error", message: "Logging Event")
        reloadLogOutput()
    }
    
    @IBAction func purgeLogs(_ sender: Any) {
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



import UIKit
import OktaLogger
var str = "Hello, playground"
/*: ## Initialize logger */
    let destination:OktaLoggerFileLogger = OktaLoggerFileLogger(identifier: "hello.world", level: .all, defaultProperties: nil)
/*: ## Add destination to Okta Logger */
    let logger = OktaLogger(destinations: [destination])
    logger.error(eventName: "event", message: str)
/*: ## Useful Snippets */
/*: 1. Where is log file */
    let path = destination.logDirectoryAbsolutePath();
    print (path ?? "Path is Empty");
/*: 2. Print File Contents */
    let logs = destination.getLogs();
    print("# logs: \(logs.count)")
    for log in logs {
        var lineCount = 0
        let logData = String(data: log as Data, encoding: .utf8)
        
        logData?.enumerateLines { (logData, line) in
            lineCount += 1
        }
        //: how many lines in log ?
        print("total lines: \(lineCount) lines \n \(logData)")
        print (logData)
    }
/*: 3. Reset Logs */
    destination.resetLogging()
/*: 4. Print File Contents */
    let logs2 = destination.getLogs();
    print("# logs: \(logs2.count)")
    for log2 in logs {
        var lineCount = 0
        let logData = String(data: log2 as Data, encoding: .utf8)
        
        logData?.enumerateLines { (logData, line) in
            lineCount += 1
        }
        //: how many lines in log ?
        print("total lines: \(lineCount) lines \n \(logData)")
        print (logData)
    }
/*: - Note: You can see that there is only 0 lines in log */

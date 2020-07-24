import Foundation
import OktaLogger

@objc
class MockLogEvent: NSObject {
    let name: String
    let message: String?
    let properties: [AnyHashable: Any]?
    let file: String?
    let line: NSNumber?
    let funcName: String?

    init(name: String,
         message: String?,
         properties: [AnyHashable: Any]?,
         file: String?,
         line: NSNumber?,
         funcName: String?) {
        self.name = name
        self.message = message
        self.properties = properties
        self.file = file
        self.line = line
        self.funcName = funcName
    }
}

@objc
class MockLoggerDestination: OktaLoggerDestinationBase {
    var events = [MockLogEvent]()
    let serialQueue = DispatchQueue(label: UUID().uuidString)

    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {
        let event = MockLogEvent(name: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
        serialQueue.sync {
            self.events.append(event)
        }
    }
}

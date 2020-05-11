import Foundation

/**
 Dynamic logging levels for OktaLogger objects.
 
 Allows custom logger implementations to react to some log levels and not others.
 */
@objc
public class OktaLogLevel: NSObject, OptionSet {
    public let rawValue: Int
    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    @objc public static let off = OktaLogLevel(rawValue: 0)
    @objc public static let debug = OktaLogLevel(rawValue: 1 << 0)
    @objc public static let info = OktaLogLevel(rawValue: 1 << 1)
    @objc public static let warning = OktaLogLevel(rawValue: 1 << 2)
    @objc public static let uiEvent = OktaLogLevel(rawValue: 1 << 3)
    @objc public static let error = OktaLogLevel(rawValue: 1 << 4)
    @objc public static let all: OktaLogLevel = [.debug, .info, .warning, .uiEvent, .error]
    
    static func == (lhs: OktaLogLevel, rhs: OktaLogLevel) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

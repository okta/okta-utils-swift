import Foundation
import Combine

// Extension to the Date struct, defines the subtraction operator, returning the time interval between two dates
extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        // Returns the time interval between the two dates
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}


/// This code defines a Swift class `EventScenario` which represents an event that can be tracked with analytics.
class EventScenario {

    // eventName is a constant property, initialized with the value passed to the init method
    private let eventName: EventName
    // properties is a dictionary of strings, initialized as an empty dictionary
    private var properties: Properties = [:]
    // time is a property of type Date, initialized as the current date
    private var time = Date()

    // eventStream is a PassthroughSubject, which is private set
    public private(set) var eventStream: PassthroughSubject<Property, Never>?

    // cancellable is an AnyCancellable, which is private
    private var cancellable: AnyCancellable?
    // isPaused is a private property which is a boolean, initialized as false
    private var isPaused = false

    // User defaults object to store properties
    private let userDefaults: UserDefaults

    private var eventDateKey: String {
        "EventDate" + eventName
    }

    private let scenarioCompletion: (Properties) -> Void?

    private let scenarioStatusPropertyKey = "ScenarioStatus"
    private let durationMSPropertyKey = "DurationMS"

    var isEventExpiredOrInterrupted: Bool {
        time.distance(to: Date()) > 5.0 * 60 /* secs */
    }

    // Initializer which assigns the passed in name to the eventName property
    init(_ eventName: EventName, userDefaults: UserDefaults = UserDefaults.standard, _ scenarioCompletion: @escaping (Properties) -> Void) {
        self.eventName = eventName
        self.userDefaults = userDefaults
        self.scenarioCompletion = scenarioCompletion
    }

    // Method which starts the event stream, assigns the current time to the time property and sets up a sink to receive values
    func start() -> PassthroughSubject<Property, Never>? {

        // check if previous event exists in memory without ended
        if let properties = userDefaults.value(forKey: eventName) as? Properties,
           let eventDate = userDefaults.value(forKey: eventDateKey) as? Date {
            var properties = properties
            var eventStatus = EventScenario.Status.expired
            if eventDate.distance(to: Date()) < 5 * 60 /* secs */ {
                eventStatus = .interrupted
            }

            properties?[scenarioStatusPropertyKey] = eventStatus.rawValue
            properties?[durationMSPropertyKey] = "\(eventDate.distance(to: Date()) * 1000)"
            scenarioCompletion(properties)
            userDefaults.removeObject(forKey: eventName)
            userDefaults.removeObject(forKey: eventDateKey)
            eventStream = nil
        }

        if let eventStream = eventStream {
            return eventStream
        }

        eventStream = PassthroughSubject()
        time = Date()

        // Save Event date to use next time for pending events that was not sent to provider
        userDefaults.set(time, forKey: eventDateKey)

        cancellable = eventStream?
            .sink { [weak self] completion in
                guard let `self` = self else { return }
                switch completion {
                case .finished:
                    self.properties?[self.scenarioStatusPropertyKey] = EventScenario.Status.completed.rawValue
                    self.end()
                case .failure:
                    self.end()
                }
            } receiveValue: { [weak self] property in
                guard let `self` = self else { return }
                self.properties?[property.key] = property.value
                self.userDefaults.set(self.properties, forKey: self.eventName)
            }
        return eventStream
    }

    // Method which cancels the cancellable, and prints the time interval since the event was started
    private func end() {
        properties?[durationMSPropertyKey] = "\(time.distance(to: Date()) * 1000)"
        scenarioCompletion(properties)
        dispose()
    }

    // Method which calls the end method and sets the eventStream to nil
    func dispose() {
        cancellable?.cancel()
        eventStream = nil
        userDefaults.removeObject(forKey: eventName)
    }

    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
}

extension EventScenario {
    enum Status: String {
        case completed
        case expired
        case interrupted
    }
}

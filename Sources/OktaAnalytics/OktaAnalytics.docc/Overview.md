
#  OktaAnalytics


![](https://user-images.githubusercontent.com/491437/192922456-1d78ad47-8c03-4e97-8260-d08375ee54a8.svg)


`OktaAnalytics` is a pod that's useful to track `Analytics`, right now we are supporting `AppCenter` and dependent on `OktaLogger` framework.

OktaAnalytics has functions to add, remove, purge providers and trackevent functions.

Steps to use `OktaAnalytics`

- Client have to implement `AnalyticsProviderProtocol` and provide information about provider (or) use create `AppCenterAnalyticsProvider` instance by providing `AppCenterAnalytics.Analytics.Type` with `init`

if client is implementing `AnalyticsProviderProtocol` protocol, `func trackEvent(_ eventName: String, withProperties: [String: String]?)` has to be overridden and add tracking event calls of provider by the client.

- If client use `AppCenterAnalyticsProvider`, needs to register/start services using `start(withAppSecret appSecret:, services:)`

- Add `AnalyticsProviderProtocol` type instance to `OktaAnalytics` using `addProvider(_: provider)` function

```swift

OktaAnalytics.addProvider(appCenterAnalyticsProvider)

```

- Now the provider is added to `OktaAnalytics` and user can track the events using `trackEvent(eventName:, withProperties:)` to track events to the provider.

## Dependencies

 - [OktaLogger](https://github.com/okta/okta-utils-swift/tree/master/Sources/OktaLogger)
 - [OktaSQLiteStorage](https://github.com/okta/okta-utils-swift/tree/master/Sources/OktaSQLiteStorage)
 - [AppCenter](https://github.com/microsoft/appcenter-sdk-apple)

## Scenario Design
![](https://github.com/okta/okta-utils-swift/assets/130079620/48ac1514-8a09-40bb-a1f9-620f161bb77f)
 
 Sceanrio is the way of tracking the user flow to Analytics provider.
 
 ## Scenario DB Design
 ![](https://github.com/okta/okta-utils-swift/assets/130079620/83b08e25-e362-40a5-b46c-db3387ab9222)

# Design
## Goal
We want to build a logging SDK and have the ability to log event to IDE, Pendo, Firebase, etc.
## Common operation
- Should be compatible with swift and objective c
- Different logger classes for different outputs 
- Okta back end API
- Log to the local file system 
- A common identifier for the device that gets passed to all logs, this identifier will be created at the time of installation of the app.
- A configuration object that could be passed to all loggers or can be customized for one logger. hierarchy of logger configuration. 
- Some loggers might have their own unique identifier and we should have a way to pass that identifier to either User-agent or other loggers 
- Need a way to dynamically change the log level 
- Need a way to dynamically add a new logger while the app is running. 

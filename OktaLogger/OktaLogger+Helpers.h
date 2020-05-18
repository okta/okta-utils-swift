@import Foundation;
@class OktaLogger;

/*
 Get/Set the logger instance used for Objective-C Macros
 */
OktaLogger *DefaultLogger(void);
void setDefaultLogger(OktaLogger *logger);

#define okl_debug(e, s, ... ) [DefaultLogger() debugWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_info(e, s, ... ) [DefaultLogger() infoWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_warn(e, s, ... ) [DefaultLogger() warningWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_uievent(e, s, ... ) [DefaultLogger() uiEventWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_error(e, s, ... ) [DefaultLogger() errorWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];


#define okl_debug(event, fmt_string, ... ) [OktaLogger.main debugWithEventName:event message:[NSString stringWithFormat:(fmt_string), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_info(event, fmt_string, ... ) [OktaLogger.main infoWithEventName:event message:[NSString stringWithFormat:(fmt_string), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_warn(event, fmt_string, ... ) [OktaLogger.main warningWithEventName:event message:[NSString stringWithFormat:(fmt_string), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_uievent(event, fmt_string, ... ) [OktaLogger.main uiEventWithEventName:event message:[NSString stringWithFormat:(fmt_string), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_error(event, fmt_string, ... ) [OktaLogger.main errorWithEventName:event message:[NSString stringWithFormat:(fmt_string), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];


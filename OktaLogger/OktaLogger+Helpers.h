#define okl_debug(e, s, ... ) [OktaLogger.shared debugWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_info(e, s, ... ) [OktaLogger.shared infoWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_warn(e, s, ... ) [OktaLogger.shared warningWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_uievent(e, s, ... ) [OktaLogger.shared uiEventWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_error(e, s, ... ) [OktaLogger.shared errorWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];


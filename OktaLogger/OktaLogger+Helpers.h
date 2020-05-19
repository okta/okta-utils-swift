#define okl_debug(e, s, ... ) [OktaLogger.main debugWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_info(e, s, ... ) [OktaLogger.main infoWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_warn(e, s, ... ) [OktaLogger.main warningWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_uievent(e, s, ... ) [OktaLogger.main uiEventWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];

#define okl_error(e, s, ... ) [OktaLogger.main errorWithEventName:e message:[NSString stringWithFormat:(s), ##__VA_ARGS__] properties:nil file:[NSString stringWithUTF8String:__FILE__] line:@(__LINE__) funcName:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]];


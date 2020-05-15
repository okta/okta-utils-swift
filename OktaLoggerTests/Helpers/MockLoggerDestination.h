#import <Foundation/Foundation.h>
#import <OktaLogger/OktaLogger.h>

NS_ASSUME_NONNULL_BEGIN

@interface MockLoggerDestination: NSObject<OktaLoggerDestination>
@property NSMutableArray<NSString *> *logs;
@end

NS_ASSUME_NONNULL_END

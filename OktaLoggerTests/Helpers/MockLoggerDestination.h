#import <Foundation/Foundation.h>
@import OktaLogger;

NS_ASSUME_NONNULL_BEGIN

@interface MockLoggerDestination: NSObject<OktaLoggerDestinationProtocol>
@property NSMutableArray<NSString *> *logs;
@end

NS_ASSUME_NONNULL_END

#import "MockLoggerDestination.h"

@implementation MockLoggerDestination
@synthesize identifier;
@synthesize level;
@synthesize defaultProperties;

- (instancetype)init {
    self = [super init];
    if (self) {
        _logs = [NSMutableArray new];
        level = OktaLogLevel.all;
    }
    return self;
}

- (void)logWithLevel:(OktaLogLevel * _Nonnull)level eventName:(NSString * _Nonnull)eventName message:(NSString * _Nullable)message properties:(NSDictionary *)properties file:(NSString * _Nonnull)file line:(NSNumber * _Nonnull)line funcName:(NSString * _Nonnull)funcName {
    [self.logs addObject:eventName];
}




@end

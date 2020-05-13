
#import <XCTest/XCTest.h>
@import okta_logger_swift;

@interface OktaLoggerTests : XCTestCase

@end

@implementation OktaLoggerTests

- (void)testSyntax {
    // testing basic syntax in Objective-c. It's not pretty yet :)
    // TODO:: ADD Objective-C macro, consider alternate obj-c names
    OktaLogger *logger = [[OktaLogger alloc] init];
    [logger debugWithEventName:@"hello" message:@"world" properties:nil file:nil line:nil column:nil funcName:nil];
    [logger infoWithEventName:@"hello" message:@"world" properties:nil file:nil line:nil column:nil funcName:nil];
    [logger warningWithEventName:@"hello" message:@"world" properties:nil file:nil line:nil column:nil funcName:nil];
    [logger errorWithEventName:@"hello" message:@"world" properties:nil file:nil line:nil column:nil funcName:nil];
    [logger uiEventWithEventName:@"hello" message:@"world" properties:nil file:nil line:nil column:nil funcName:nil];
}

@end

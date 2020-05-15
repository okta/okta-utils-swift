
#import <XCTest/XCTest.h>
#import "OktaLogger+Helpers.h"
#import "MockLoggerDestination.h"

@interface OktaLoggerTests : XCTestCase

@end

@implementation OktaLoggerTests

// Test the basic macro syntax and verify that the logs are populated
- (void)testMacroSyntax {
    OktaLogger *logger = [[OktaLogger alloc] init];
    MockLoggerDestination *destination = [MockLoggerDestination new];
    [logger addDestination:destination];
    setDefaultLogger(logger);
    
    OLogDebug(@"event", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 1);
    OLogInfo(@"event", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 2);
    OLogWarning(@"event", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 3);
    OLogUiEvent(@"event", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 4);
    OLogError(@"error", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 5);
}

@end

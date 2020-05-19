
#import <XCTest/XCTest.h>
#import "OktaLogger+Helpers.h"
#import "MockLoggerDestination.h"

@interface OktaLoggerTests : XCTestCase

@end

@implementation OktaLoggerTests

// Test the basic macro syntax and verify that the logs are populated
- (void)testMacroSyntax {
    MockLoggerDestination *destination = [MockLoggerDestination new];
    OktaLogger *logger = [[OktaLogger alloc] initWithDestinations:@[destination]];
    OktaLogger.main = logger;
    
    okl_debug(@"event", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 1);
    okl_info(@"event", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 2);
    okl_warn(@"event", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 3);
    okl_uievent(@"event", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 4);
    okl_error(@"error", @"%@", @"world");
    XCTAssertEqual(destination.logs.count, 5);
}

@end

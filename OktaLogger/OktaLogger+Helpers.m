#import "OktaLogger+Helpers.h"
#import <Foundation/Foundation.h>

static OktaLogger *_ol = nil;

OktaLogger *DefaultLogger() {
    @synchronized (_ol) {
        return _ol;
    }
}

void setDefaultLogger(OktaLogger *logger) {
    @synchronized (_ol) {
        _ol = logger;
    }
}

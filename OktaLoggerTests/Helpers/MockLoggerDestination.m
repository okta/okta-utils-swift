/*
 * Copyright (c) 2020-Present, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */
#import "MockLoggerDestination.h"

@implementation MockLoggerDestination
@synthesize identifier;
@synthesize level;
@synthesize defaultProperties;

- (instancetype)init {
    self = [super init];
    if (self) {
        _logs = [NSMutableArray new];
        level = OktaLoggerLogLevel.all;
    }
    return self;
}

- (void)logWithLevel:(OktaLoggerLogLevel * _Nonnull)level eventName:(NSString * _Nonnull)eventName message:(NSString * _Nullable)message properties:(NSDictionary *)properties file:(NSString * _Nonnull)file line:(NSNumber * _Nonnull)line funcName:(NSString * _Nonnull)funcName {
    [self.logs addObject:eventName];
}




@end

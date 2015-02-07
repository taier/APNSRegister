//
//  APNSRegister.h
//  APNSRegister
//
//  Created by Deniss Kaibagarovs on 2/7/15.
//  Copyright (c) 2015 Deniss Kaibagarovs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TokenRegisterServiceProtocol.h"

@protocol TokenRegisterServiceDelegate

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSString *)token;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

@end

@interface TokenRegisterService : NSObject <TokenRegisterServiceProtocol>

@property id <TokenRegisterServiceDelegate> tokenRegisterServiceDelegate;;

+ (TokenRegisterService *)sharedInstance;

@end

//
//  TokenRegisterServiceProtocol.h
//  APNSRegister
//
//  Created by Deniss Kaibagarovs on 2/7/15.
//  Copyright (c) 2015 Deniss Kaibagarovs. All rights reserved.
//

@protocol TokenRegisterServiceProtocol

- (void)registerForRemoteNotifications;
- (void)unregisterForRemoteNotifications;

@end
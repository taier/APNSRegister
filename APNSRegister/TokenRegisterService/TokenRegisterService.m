//
//  APNSRegister.m
//  APNSRegister
//
//  Created by Deniss Kaibagarovs on 2/7/15.
//  Copyright (c) 2015 Deniss Kaibagarovs. All rights reserved.
//

#import "TokenRegisterService.h"
#import <UIKit/UIKit.h>
#include <objc/runtime.h>

#define IS_OS_8_OR_LATER  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface TokenRegisterService () 

// Private Methods
void p_registerForRemoteNotifications();
void p_unregisterForRemoteNotifications();

// Overridden Delegates
void didRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication* application, NSData* deviceToken);
void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication* application, NSError* error);

@end

@implementation TokenRegisterService

#pragma mark Live Circle

+ (TokenRegisterService *)sharedInstance {
    static TokenRegisterService *_sharedClass = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClass = [[self alloc] init];
    });
    
    return _sharedClass;
}

#pragma mark Protocol Methods

- (void)registerForRemoteNotifications {
    p_registerForRemoteNotifications();
}
- (void)unregisterForRemoteNotifications {
    p_unregisterForRemoteNotifications();
}

#pragma mark Private Methods

void p_registerForRemoteNotifications() {
    NSLog(@"Registering app for remote notifications.");
    
    // Modify UIApplicationDelegate, to silently receive delegates. Without touching (writing any code in) AppDelegate.
    id delegate = [[UIApplication sharedApplication] delegate];
    Class objectClass = object_getClass(delegate);
    
    NSString *newClassName = [NSString stringWithFormat:@"Custom_%@", NSStringFromClass(objectClass)];
    Class modDelegate = NSClassFromString(newClassName);
    
    if (modDelegate == nil) {
        // This class doesn't exist; create it.
        // Allocate a new class
        modDelegate = objc_allocateClassPair(objectClass, [newClassName UTF8String], 0);
        
        SEL selectorToOverride1 = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
        SEL selectorToOverride2 = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
        
        // Get the info on the method we're going to override
        Method m1 = class_getInstanceMethod([TokenRegisterService class], selectorToOverride1);
        Method m2 = class_getInstanceMethod([TokenRegisterService class], selectorToOverride2);
        
        // Add the method to the new class
        class_addMethod(modDelegate, selectorToOverride1, (IMP)didRegisterForRemoteNotificationsWithDeviceToken, method_getTypeEncoding(m1));
        class_addMethod(modDelegate, selectorToOverride2, (IMP)didFailToRegisterForRemoteNotificationsWithError, method_getTypeEncoding(m2));
        
        // Register the new class with the runtime
        objc_registerClassPair(modDelegate);
    }
     // Change the class of the object
     object_setClass(delegate, modDelegate);
     
     // Register this app for remote notifications
     if(IS_OS_8_OR_LATER) { // For iOS 7 and 8 there are different ways for register
         UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert
                                                             | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
         [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
         [[UIApplication sharedApplication] registerForRemoteNotifications];
     } else {
         [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
          (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge)];
     }
}

void p_unregisterForRemoteNotifications() {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
     NSLog(@"Did unregister device");
}

#pragma mark Overrided Delegates

void didRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication* application, NSData* deviceToken) {
    const unsigned *tokenBytes = [deviceToken bytes];
    // Why not description? Nothing ensures that latest versions of iOS will not change the implementation and result of this call. 
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSLog(@"Did register with device token: %@",hexToken);
    // A bit ugly, because self in this context is modified delegate
    [[[TokenRegisterService sharedInstance] tokenRegisterServiceDelegate] didRegisterForRemoteNotificationsWithDeviceToken:hexToken];
}

void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication* application, NSError* error) {
    NSLog(@"Failed to register device - %@", [error description]);
    // A bit ugly, because self in this context is modified delegate
    [[[TokenRegisterService sharedInstance] tokenRegisterServiceDelegate] didFailToRegisterForRemoteNotificationsWithError:error];
}

@end

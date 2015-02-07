//
//  ViewController.m
//  APNSRegister
//
//  Created by Deniss Kaibagarovs on 2/7/15.
//  Copyright (c) 2015 Deniss Kaibagarovs. All rights reserved.
//

#import "ViewController.h"
#import "TokenRegisterService.h"

@interface ViewController () <TokenRegisterServiceDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TokenRegisterService sharedInstance].tokenRegisterServiceDelegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Buttons

- (IBAction)buttonRegisterPressed:(id)sender {
    [[TokenRegisterService sharedInstance] registerForRemoteNotifications];
}
- (IBAction)buttonUnRegisterPressed:(id)sender {
    [[TokenRegisterService sharedInstance] unregisterForRemoteNotifications];
}

#pragma mark TokenRegisterServiceDelegate

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSString *)token {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:[NSString stringWithFormat:@"Token: %@", token]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end

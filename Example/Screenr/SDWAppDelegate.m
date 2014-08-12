//
//  SDWAppDelegate.m
//  Screenr
//
//  Created by alex on 6/26/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import "ScreenCare.h"
#import "SDWAppDelegate.h"
#import "SDWSimpleMasterVC.h"

@implementation SDWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    ScreenCare *SER = [[ScreenCare alloc]initWithUploadCareKey:@"47723df3799764bc67fb" slackHookUrl:@"https://riders.slack.com/services/hooks/incoming-webhook?token=zOoXaDmovLPqMJXPw9dkbaV0"];
//    [self.window.rootViewController.view addSubview:SER.view];
//    [self.window makeKeyAndVisible];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - State restoration

#define BUNDLEMINVERSION 1

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {

    // Retrieve the Bundle Version Key so we can check if the restoration data is from an older
    // version of the App that would not make sense to restore. This might be the case after we
    // have made significant changes to the view hierarchy.

    NSString *restorationBundleVersion = [coder decodeObjectForKey:UIApplicationStateRestorationBundleVersionKey];
    if ([restorationBundleVersion integerValue] < BUNDLEMINVERSION) {
        NSLog(@"Ignoring restoration data for bundle version: %@",restorationBundleVersion);
        return NO;
    }

    // Retrieve the User Interface Idiom (iPhone or iPad) for the device that created the restoration Data.
    // This allows us to ignore the restoration data when the user interface idiom that created the data
    // does not match the current device user interface idiom.

    UIDevice *currentDevice = [UIDevice currentDevice];
    UIUserInterfaceIdiom restorationInterfaceIdiom = [[coder decodeObjectForKey:UIApplicationStateRestorationUserInterfaceIdiomKey] integerValue];
    UIUserInterfaceIdiom currentInterfaceIdiom = currentDevice.userInterfaceIdiom;
    if (restorationInterfaceIdiom != currentInterfaceIdiom) {
        NSLog(@"Ignoring restoration data for interface idiom: %d",restorationInterfaceIdiom);
        return NO;
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    
    return YES;
}



- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return [self launchWithOptions:launchOptions];
}


- (BOOL)launchWithOptions:(NSDictionary *)launchOptions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        // Override point for customization after application launch.


        SDWSimpleMasterVC *table = [[SDWSimpleMasterVC alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:table];
        navCon.restorationIdentifier = @"navigationController";

        self.window.rootViewController = navCon;

        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];

    });
    
    return YES;
}


@end

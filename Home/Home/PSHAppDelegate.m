//
//  PSHAppDelegate.m
//  Home
//
//  Created by Kenny Tang on 4/21/13.
//  Copyright (c) 2013 com.corgitoergosum.net. All rights reserved.
//

#import "PSHAppDelegate.h"
#import "PSHHomeViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "DDFileLogger.h"

int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PSHAppDelegate()


@end


@implementation PSHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Home.sqlite"];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    PSHHomeViewController * vc = [[PSHHomeViewController alloc] init];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.rootViewController = navController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

#pragma mark - set up lumberjack

- (void)setupLogging {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setRollingFrequency:60 * 60 * 24];   // roll every day
    [fileLogger setMaximumFileSize:1024 * 1024 * 2]; // max 2mb file size
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:7];
    
    [DDLog addLogger:fileLogger];
    
    DDLogVerbose(@"Logging is setup (\"%@\")", [fileLogger.logFileManager logsDirectory]);
}

#pragma mark - XMPP Service



@end

//
//  DB5AppDelegate.m
//  DB5Demo
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2013 Q Branch LLC. All rights reserved.
//

#import "DB5AppDelegate.h"
#import "DB5ViewController.h"
#import "VSThemeLoader.h"
#import "VSTheme.h"


@interface DB5AppDelegate ()

@property (nonatomic, strong) VSThemeLoader *themeLoader;

@end


@implementation DB5AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.themeLoader = [VSThemeLoader new];
    __weak DB5AppDelegate* wself = self;
    self.themeLoader.themeReloadedCallback = ^{[wself reloadViewController];};
    [self reloadViewController];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)reloadViewController
{
    [self.themeLoader loadThemes];
    self.viewController = [[DB5ViewController alloc] initWithNibName:@"DB5ViewController" bundle:nil theme:self.themeLoader.defaultTheme];
    self.window.rootViewController = self.viewController;
}



@end

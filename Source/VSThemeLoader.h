//
//  VSThemeLoader.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^ThemeReloadedCallback)(void);

@class VSTheme;

@interface VSThemeLoader : NSObject

@property (nonatomic, strong, readonly) VSTheme *defaultTheme;
@property (nonatomic, strong, readonly) NSArray *themes;
@property (nonatomic, copy) ThemeReloadedCallback themeReloadedCallback;
- (id)initWithFileName:(NSString *)fileName;
+ (VSThemeLoader *)sharedThemeLoader;
- (VSTheme *)themeNamed:(NSString *)themeName;
- (void)loadThemes;

@end

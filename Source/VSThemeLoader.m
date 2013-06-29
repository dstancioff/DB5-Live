//
//  VSThemeLoader.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import "VSThemeLoader.h"
#import "VSTheme.h"


@interface VSThemeLoader ()

@property (nonatomic, strong, readwrite) VSTheme *defaultTheme;
@property (nonatomic, strong, readwrite) NSArray *themes;
@property (nonatomic) NSTimeInterval lastThemeModificationDate;
@end


@implementation VSThemeLoader


- (id)init {
	
	self = [super init];
	if (self == nil)
		return nil;
	
    self.lastThemeModificationDate = [[NSDate date] timeIntervalSinceReferenceDate];
    [self loadThemes];
    [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(pollFileSystem:) userInfo:nil repeats:YES];
	return self;
}

- (void)loadThemes
{
    NSString *themesFilePath = [[NSBundle mainBundle] pathForResource:@"DB5" ofType:@"plist"];
	NSDictionary *themesDictionary = [NSDictionary dictionaryWithContentsOfFile:themesFilePath];
	
	NSMutableArray *themes = [NSMutableArray array];
	for (NSString *oneKey in themesDictionary) {
		
		VSTheme *theme = [[VSTheme alloc] initWithDictionary:themesDictionary[oneKey]];
		if ([[oneKey lowercaseString] isEqualToString:@"default"])
			_defaultTheme = theme;
		theme.name = oneKey;
		[themes addObject:theme];
	}
    
    for (VSTheme *oneTheme in themes) { /*All themes inherit from the default theme.*/
		if (oneTheme != _defaultTheme)
			oneTheme.parentTheme = _defaultTheme;
    }
    
	_themes = themes;

}

- (VSTheme *)themeNamed:(NSString *)themeName {

	for (VSTheme *oneTheme in self.themes) {
		if ([themeName isEqualToString:oneTheme.name])
			return oneTheme;
	}

	return nil;
}

-(void)pollFileSystem:(NSTimer*)timer
{
#if TARGET_IPHONE_SIMULATOR
    NSString *symlinkPath =
    [[NSFileManager defaultManager]
     destinationOfSymbolicLinkAtPath:[[NSBundle mainBundle] pathForResource:@"DB5" ofType:@"plist" inDirectory:nil]
     error:NULL];
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:symlinkPath error:nil];
    NSDate* modifiedDate = [fileAttributes objectForKey:NSFileModificationDate];
    NSTimeInterval modifiedTimeInterval = [modifiedDate timeIntervalSinceReferenceDate];
    if(self.lastThemeModificationDate > 0 && [modifiedDate timeIntervalSinceReferenceDate] > self.lastThemeModificationDate)
    {
        self.themeReloadedCallback();
        NSLog(@"Themes Refreshed");
    }
    self.lastThemeModificationDate = modifiedTimeInterval;
#endif
    
}


@end

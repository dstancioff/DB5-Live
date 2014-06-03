//
//  VSTheme.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import "VSTheme.h"


static BOOL stringIsEmpty(NSString *s);
static UIColor *colorWithHexString(NSString *hexString);


@interface VSTheme ()

@property (nonatomic, strong) NSDictionary *themeDictionary;
@property (nonatomic, strong) NSCache *colorCache;
@property (nonatomic, strong) NSCache *fontCache;
@property (nonatomic, strong) NSCache *shadowCache;

@end


@implementation VSTheme

static VSTheme *_defaultTheme;
static NSArray *_themes;
static NSTimeInterval _lastThemesFileModificationDate;
static ThemesDidReloadHandler _themesReloadedHandler;

+ (void)initialize {
    
    [self reloadThemes];
    
#if TARGET_IPHONE_SIMULATOR
    [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(pollFileSystem:) userInfo:nil repeats:YES];
#endif
}

+ (void)reloadThemes {
    
    _lastThemesFileModificationDate = [[NSDate date] timeIntervalSinceReferenceDate];
    NSString *fileName = @"DB5";

    NSString *themesFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	NSDictionary *themesDictionary = [NSDictionary dictionaryWithContentsOfFile:themesFilePath];
	
	NSMutableArray *themes = [NSMutableArray array];
	for (NSString *oneKey in themesDictionary)
    {
		
		VSTheme *theme = [[[self class] alloc] initWithDictionary:themesDictionary[oneKey]];
		if ([[oneKey lowercaseString] isEqualToString:@"default"])
			_defaultTheme = theme;
		theme.name = oneKey;
		[themes addObject:theme];
	}
    
    for (VSTheme *oneTheme in themes)
    { /*All themes inherit from the default theme.*/
		if (oneTheme != _defaultTheme)
			oneTheme.parentTheme = _defaultTheme;
    }
    
	_themes = themes;
    
}

+ (void)pollFileSystem:(NSTimer*)timer {
    
#if TARGET_IPHONE_SIMULATOR
    NSString *symlinkPath =
    [[NSFileManager defaultManager]
     destinationOfSymbolicLinkAtPath:[[NSBundle mainBundle] pathForResource:@"DB5" ofType:@"plist" inDirectory:nil]
     error:NULL];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:symlinkPath error:nil];
    NSDate *modifiedDate = [fileAttributes objectForKey:NSFileModificationDate];
    NSTimeInterval modifiedTimeInterval = [modifiedDate timeIntervalSinceReferenceDate];
    if (_lastThemesFileModificationDate > 0 && [modifiedDate timeIntervalSinceReferenceDate] > _lastThemesFileModificationDate)
    {
        [self reloadThemes];
        if (_themesReloadedHandler)
        {
            _themesReloadedHandler();
        }
        NSLog(@"Themes Refreshed");
    }
    _lastThemesFileModificationDate = modifiedTimeInterval;
#endif
    
}

+ (void)setThemesDidReloadHandler:(ThemesDidReloadHandler)block {
    
    _themesReloadedHandler = block;
}

+ (VSTheme *)themeNamed:(NSString *)themeName {
    
	for (VSTheme *oneTheme in _themes)
    {
		if ([themeName isEqualToString:oneTheme.name])
			return oneTheme;
	}
    
	return nil;
}

+ (instancetype)defaultTheme {
    
    return _defaultTheme;
}

#pragma mark Init

- (id)initWithDictionary:(NSDictionary *)themeDictionary {
	
	self = [super init];
	if (self == nil)
		return nil;
	
	_themeDictionary = themeDictionary;

	_colorCache = [NSCache new];
	_fontCache = [NSCache new];

	return self;
}


- (id)objectForKey:(NSString *)key {

	id obj = [self.themeDictionary valueForKeyPath:key];
	if (obj == nil && self.parentTheme != nil)
		obj = [self.parentTheme objectForKey:key];
	return obj;
}


- (BOOL)boolForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	if (obj == nil)
		return NO;
	return [obj boolValue];
}


- (NSString *)stringForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	if (obj == nil)
		return nil;
	if ([obj isKindOfClass:[NSString class]])
		return obj;
	if ([obj isKindOfClass:[NSNumber class]])
		return [obj stringValue];
	return nil;
}


- (NSInteger)integerForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	if (obj == nil)
		return 0;
	return [obj integerValue];
}


- (CGFloat)floatForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	if (obj == nil)
		return  0.0f;
	return [obj floatValue];
}


- (NSTimeInterval)timeIntervalForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	if (obj == nil)
		return 0.0;
	return [obj doubleValue];
}


- (UIImage *)imageForKey:(NSString *)key {
	
	NSString *imageName = [self stringForKey:key];
	if (stringIsEmpty(imageName))
		return nil;
	
	return [UIImage imageNamed:imageName];
}


- (UIColor *)colorForKey:(NSString *)key {

	UIColor *cachedColor = [self.colorCache objectForKey:key];
	if (cachedColor != nil)
		return cachedColor;
    
	NSString *colorString = [self stringForKey:key];

    UIColor *color;
    // Support for RGB and RGBA in 255 (spaces ignored)
    if ([colorString rangeOfString:@","].location != NSNotFound) {
        colorString = [colorString stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *colorComponents = [colorString componentsSeparatedByString:@","];
        if ([colorComponents count] == 3 || [colorComponents count] == 4) {
            float red = [colorComponents[0] floatValue] / 255.0f;
            float green = [colorComponents[1] floatValue] / 255.0f;
            float blue = [colorComponents[2] floatValue] / 255.0f;
            float alpha = 1.0;
            if ([colorComponents count] == 4) {
                alpha = [colorComponents[3] floatValue] / 255.0f;
            }
            color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        }
    }
    else
    {
        color = colorWithHexString(colorString);
    }
	if (color == nil)
		color = [UIColor purpleColor];

	[self.colorCache setObject:color forKey:key];

	return color;
}


- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key {

	CGFloat left = [self floatForKey:[key stringByAppendingString:@"Left"]];
	CGFloat top = [self floatForKey:[key stringByAppendingString:@"Top"]];
	CGFloat right = [self floatForKey:[key stringByAppendingString:@"Right"]];
	CGFloat bottom = [self floatForKey:[key stringByAppendingString:@"Bottom"]];

	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
	return edgeInsets;
}


- (UIFont *)fontForKey:(NSString *)key {

	UIFont *cachedFont = [self.fontCache objectForKey:key];
	if (cachedFont != nil)
		return cachedFont;
    
	NSString *fontName = [self stringForKey:key];
	CGFloat fontSize = [self floatForKey:[key stringByAppendingString:@"Size"]];

	if (fontSize < 1.0f)
		fontSize = 15.0f;

	UIFont *font = nil;
    
	if (stringIsEmpty(fontName))
		font = [UIFont systemFontOfSize:fontSize];
	else
		font = [UIFont fontWithName:fontName size:fontSize];

	if (font == nil)
		font = [UIFont systemFontOfSize:fontSize];
    
	[self.fontCache setObject:font forKey:key];

	return font;
}


- (NSShadow *)shadowForKey:(NSString *)key {
    
    NSShadow *cachedShadow = [self.shadowCache objectForKey:key];
    if (cachedShadow != nil) {
        return cachedShadow;
    }
    
    NSShadow *shadow = [NSShadow new];
    
    shadow.shadowOffset = [self sizeForKey:[key stringByAppendingString:@"Offset"]];
    shadow.shadowColor = [self colorForKey:[key stringByAppendingString:@"Color"]];
    shadow.shadowBlurRadius = [self floatForKey:[key stringByAppendingString:@"Radius"]];
    
    [self.shadowCache setObject:shadow forKey:key];
    
    return shadow;
}


- (CGPoint)pointForKey:(NSString *)key {
    NSString *pointString = [self stringForKey:key];
    if (pointString && [pointString rangeOfString:@","].location != NSNotFound) {
        NSArray *pointComponents = [pointString componentsSeparatedByString:@","];
        if ([pointComponents count] == 2) {
            CGFloat x = [pointComponents[0] floatValue];
            CGFloat y = [pointComponents[1] floatValue];
            return CGPointMake(x, y);
        }
        NSLog(@"DB5: Unable to find point for key %@", key);
        return CGPointZero;
    }
	CGFloat pointX = [self floatForKey:[key stringByAppendingString:@"X"]];
	CGFloat pointY = [self floatForKey:[key stringByAppendingString:@"Y"]];

	CGPoint point = CGPointMake(pointX, pointY);
	return point;
}


- (CGSize)sizeForKey:(NSString *)key {
    NSString *sizeString = [self stringForKey:key];
    if (sizeString && [sizeString rangeOfString:@","].location != NSNotFound) {
        NSArray *sizeComponents = [sizeString componentsSeparatedByString:@","];
        if ([sizeComponents count] == 2) {
            CGFloat x = [sizeComponents[0] floatValue];
            CGFloat y = [sizeComponents[1] floatValue];
            return CGSizeMake(x, y);
        }
        NSLog(@"DB5: Unable to find size for key %@", key);
        return CGSizeZero;
    }
    CGFloat width = [self floatForKey:[key stringByAppendingString:@"Width"]];
    CGFloat height = [self floatForKey:[key stringByAppendingString:@"Height"]];
    CGSize size = CGSizeMake(width, height);
    return size;
}


- (CGRect)rectForKey:(NSString*)key {
    NSString* rectString = [self stringForKey:key];
    if (rectString && [rectString rangeOfString:@","].location != NSNotFound) {
        NSArray *rectComponents = [rectString componentsSeparatedByString:@","];
        if ([rectComponents count] == 4) {
            CGFloat x = [rectComponents[0] floatValue];
            CGFloat y = [rectComponents[1] floatValue];
            CGFloat w = [rectComponents[2] floatValue];
            CGFloat h = [rectComponents[3] floatValue];
            return CGRectMake(x, y, w, h);
        }
        NSLog(@"DB5: Unable to find rect for key %@", key);
        return CGRectZero;
    }
    return (CGRect){[self pointForKey:key], [self sizeForKey:key]};

}

- (UIViewAnimationOptions)curveForKey:(NSString *)key {
    
	NSString *curveString = [self stringForKey:key];
	if (stringIsEmpty(curveString))
		return UIViewAnimationOptionCurveEaseInOut;

	curveString = [curveString lowercaseString];
	if ([curveString isEqualToString:@"easeinout"])
		return UIViewAnimationOptionCurveEaseInOut;
	else if ([curveString isEqualToString:@"easeout"])
		return UIViewAnimationOptionCurveEaseOut;
	else if ([curveString isEqualToString:@"easein"])
		return UIViewAnimationOptionCurveEaseIn;
	else if ([curveString isEqualToString:@"linear"])
		return UIViewAnimationOptionCurveLinear;
    
	return UIViewAnimationOptionCurveEaseInOut;
}


- (VSAnimationSpecifier *)animationSpecifierForKey:(NSString *)key {

	VSAnimationSpecifier *animationSpecifier = [VSAnimationSpecifier new];

	animationSpecifier.duration = [self timeIntervalForKey:[key stringByAppendingString:@"Duration"]];
	animationSpecifier.delay = [self timeIntervalForKey:[key stringByAppendingString:@"Delay"]];
	animationSpecifier.curve = [self curveForKey:[key stringByAppendingString:@"Curve"]];

	return animationSpecifier;
}


- (VSTextCaseTransform)textCaseTransformForKey:(NSString *)key {

	NSString *s = [self stringForKey:key];
	if (s == nil)
		return VSTextCaseTransformNone;

	if ([s caseInsensitiveCompare:@"lowercase"] == NSOrderedSame)
		return VSTextCaseTransformLower;
	else if ([s caseInsensitiveCompare:@"uppercase"] == NSOrderedSame)
		return VSTextCaseTransformUpper;

	return VSTextCaseTransformNone;
}

@end


@implementation VSTheme (Animations)


- (void)animateWithAnimationSpecifierKey:(NSString *)animationSpecifierKey animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {

    VSAnimationSpecifier *animationSpecifier = [self animationSpecifierForKey:animationSpecifierKey];

    [UIView animateWithDuration:animationSpecifier.duration delay:animationSpecifier.delay options:animationSpecifier.curve animations:animations completion:completion];
}

@end


#pragma mark -

@implementation VSAnimationSpecifier

@end


static BOOL stringIsEmpty(NSString *s) {
	return s == nil || [s length] == 0;
}


static UIColor *colorWithHexString(NSString *hexString) {

	/*Picky. Crashes by design.*/
	
	if (stringIsEmpty(hexString))
		return [UIColor blackColor];

	NSMutableString *s = [hexString mutableCopy];
	[s replaceOccurrencesOfString:@"#" withString:@"" options:0 range:NSMakeRange(0, [hexString length])];
	CFStringTrimWhitespace((__bridge CFMutableStringRef)s);

	NSString *redString = [s substringToIndex:2];
	NSString *greenString = [s substringWithRange:NSMakeRange(2, 2)];
	NSString *blueString = [s substringWithRange:NSMakeRange(4, 2)];

	unsigned int red = 0, green = 0, blue = 0, alpha = 255;
	[[NSScanner scannerWithString:redString] scanHexInt:&red];
	[[NSScanner scannerWithString:greenString] scanHexInt:&green];
	[[NSScanner scannerWithString:blueString] scanHexInt:&blue];
    if([s length] == 8)
    {
        NSString *alphaString = [s substringWithRange:NSMakeRange(6, 2)];
        [[NSScanner scannerWithString:alphaString] scanHexInt:&alpha];
    }

	return [UIColor colorWithRed:(CGFloat)red/255.0f green:(CGFloat)green/255.0f blue:(CGFloat)blue/255.0f alpha:alpha/255.0f];
}

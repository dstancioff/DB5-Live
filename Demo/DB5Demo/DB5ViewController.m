//
//  DB5ViewController.m
//  DB5Demo
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2013 Q Branch LLC. All rights reserved.
//

#import "DB5ViewController.h"
#import "VSTheme.h"


@interface DB5ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *label;

@end


@implementation DB5ViewController


- (void)viewDidLoad {

	self.view.backgroundColor = [[VSTheme defaultTheme] colorForKey:@"backgroundColor"];
	self.label.textColor = [[VSTheme defaultTheme] colorForKey:@"labelTextColor"];
	self.label.font = [[VSTheme defaultTheme] fontForKey:@"labelFont"];

	[[VSTheme defaultTheme] animateWithAnimationSpecifierKey:@"labelAnimation" animations:^{

		CGRect rLabel = self.label.frame;
		rLabel.origin = [[VSTheme defaultTheme] pointForKey:@"label"];

		self.label.frame = rLabel;
		
	} completion:^(BOOL finished) {
		NSLog(@"Ran an animation.");
	}];
}



@end

//
//  CKUINavigationControllerAdditions.m
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKUINavigationControllerAdditions.h"


@implementation UINavigationController (CKUINavigationControllerAdditions)

- (NSDictionary *)getStyles {
	NSMutableDictionary *styles = [NSMutableDictionary dictionary];
	[styles setObject:[NSNumber numberWithInt:[UIApplication sharedApplication].statusBarStyle] forKey:@"CKStatusBarStyle"];
	[styles setObject:[NSNumber numberWithInt:self.navigationBar.barStyle] forKey:@"CKNavigationBarStyle"];
	[styles setObject:[NSNumber numberWithInt:self.toolbar.barStyle] forKey:@"CKToolbarStyle"];
	[styles setObject:[NSNumber numberWithBool:self.navigationBar.translucent] forKey:@"CKNavigationBarTranslucent"];
	[styles setObject:[NSNumber numberWithBool:self.toolbar.translucent] forKey:@"CKToolbarTranslucent"];
	[styles setObject:[NSNumber numberWithBool:self.navigationBar.hidden] forKey:@"CKNavigationBarHidden"];
	[styles setObject:[NSNumber numberWithBool:self.toolbar.hidden] forKey:@"CKToolbarHidden"];
	if (self.navigationBar.tintColor) [styles setObject:self.navigationBar.tintColor forKey:@"CKNavigationBarTintColor"];
	if (self.toolbar.tintColor) [styles setObject:self.toolbar.tintColor forKey:@"CKToolbarTintColor"];
	return styles;
}

- (void)setStyles:(NSDictionary *)styles animated:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:[[styles objectForKey:@"CKStatusBarStyle"] intValue] animated:animated];
	self.navigationBar.barStyle = [[styles objectForKey:@"CKNavigationBarStyle"] intValue];
	self.toolbar.barStyle = [[styles objectForKey:@"CKToolbarStyle"] intValue];
	self.navigationBar.translucent = [[styles objectForKey:@"CKNavigationBarTranslucent"] boolValue];
	self.toolbar.translucent = [[styles objectForKey:@"CKToolbarTranslucent"] boolValue];
	[self setNavigationBarHidden:[[styles objectForKey:@"CKNavigationBarHidden"] boolValue] animated:animated];
	[self setToolbarHidden:[[styles objectForKey:@"CKToolbarHidden"] boolValue] animated:animated];
	self.navigationBar.tintColor = [styles objectForKey:@"CKNavigationBarTintColor"];
	self.toolbar.tintColor = [styles objectForKey:@"CKToolbarTintColor"];
}


@end

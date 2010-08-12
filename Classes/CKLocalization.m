//
//  CKLocalization.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-15.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

NSString *CKLocalizationCurrentLocalization(void) {
	NSArray *l18n = [[NSBundle mainBundle] preferredLocalizations];
	return [l18n objectAtIndex:0];
}

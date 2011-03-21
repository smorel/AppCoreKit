//
//  CKNSDictionary+TableView.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CKTableViewAttributeBounds;
extern NSString * const CKTableViewAttributePagingEnabled;
extern NSString * const CKTableViewAttributeInterfaceOrientation;
extern NSString * const CKTableViewAttributeOrientation;
extern NSString * const CKTableViewAttributeAnimationDuration;

typedef enum {
	CKTableViewOrientationPortrait,
	CKTableViewOrientationLandscape
} CKTableViewOrientation;

@interface NSDictionary (CKTableViewAttributes)

- (BOOL)pagingEnabled;
- (UIInterfaceOrientation)interfaceOrientation;
- (CGSize)bounds;
- (CKTableViewOrientation)tableOrientation;
- (NSTimeInterval)animationDuration;

@end

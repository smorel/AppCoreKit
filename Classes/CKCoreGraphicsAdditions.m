//
//  CKCoreGraphicsAdditions.m
//  CloudKit
//
//  Created by Olivier Collet on 11-01-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCoreGraphicsAdditions.h"


CGPoint CGPointOffset(CGPoint point, CGFloat x, CGFloat y) {
	CGPoint newPoint = point;
	newPoint.x += x;
	newPoint.y += y;
	return newPoint;
}
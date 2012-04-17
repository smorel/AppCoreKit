//
//  CKUIImage+Factory.m
//  CloudKit
//
//  Created by Olivier Collet on 10-07-23.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKUIImage+Factory.h"


CGFloat randomPictureAngle(int offset, int max) {
	return (rand() % (max - offset) ) + offset;
}

NSInteger randomSign() {
	return (arc4random() % 2 ? 1 : -1);
}

CGAffineTransform rotationTransform(CGSize size, CGFloat degrees) {
	CGFloat w = size.width;
	CGFloat h = size.height;
	
	CGAffineTransform translation1 = CGAffineTransformMakeTranslation((-w/2), (-h/2));
	CGAffineTransform rotation = CGAffineTransformMakeRotation( degrees * M_PI/180);
	CGAffineTransform translation2 = CGAffineTransformMakeTranslation((w/2), (h/2));
	
	return CGAffineTransformConcat(CGAffineTransformConcat(translation1, rotation), translation2);
}

//

@implementation UIImage (Factory)

+ (UIImage *)imageStack:(NSInteger)nbImages size:(CGSize)size edgeInsets:(UIEdgeInsets)insets {
	CGRect stackRect = CGRectMake(0, 0, size.width, size.height);

	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(context, stackRect);
	CGContextSaveGState(context);

	// Set the shadow
	UIColor *shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 4.0, shadowColor.CGColor);
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	
	CGRect imageRect = UIEdgeInsetsInsetRect(stackRect, insets);

	// Draw the stacked images
	for (int i=0 ; i<(nbImages - 1) ; i++) {
		CGContextSaveGState(context);
		CGContextConcatCTM(context, rotationTransform(size, randomSign() * randomPictureAngle(3, 10)));
		CGContextAddRect(context, imageRect);
		CGContextDrawPath(context, kCGPathFill);
		CGContextRestoreGState(context);		
	}

	// Draw the image on top
	CGContextSaveGState(context);
	CGContextAddRect(context, imageRect);
	CGContextDrawPath(context, kCGPathFill);
	CGContextRestoreGState(context);
	
	CGContextRestoreGState(context);
	
	UIImage *stackImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return stackImage;
}

@end

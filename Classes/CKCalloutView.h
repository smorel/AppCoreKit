//
//  CKCalloutView.h
//  YellowPages
//
//  Created by Olivier Collet on 10-06-16.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKOverlayView.h"


typedef enum {
	CKCalloutArrowDirectionUp = 0,
	CKCalloutArrowDirectionDown,
	CKCalloutArrowDirectionLeft,
	CKCalloutArrowDirectionRight,
} CKCalloutArrowDirection;


@interface CKCalloutView : CKOverlayView {
	CGFloat _arrowDeltaX;
	CGFloat _arrowDeltaY;
	
	CKCalloutArrowDirection _arrowDirection;
}

@property (nonatomic, assign) CKCalloutArrowDirection arrowDirection;

- (void)presentFromRect:(CGRect)rect inView:(UIView *)parentView animated:(BOOL)animated;

@end

//
//  CKCalloutView.h
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKOverlayView.h"


/** TODO
 */
typedef enum {
	CKCalloutArrowDirectionUp = 0,
	CKCalloutArrowDirectionDown,
	CKCalloutArrowDirectionLeft,
	CKCalloutArrowDirectionRight,
} CKCalloutArrowDirection;


/** TODO
 */
@interface CKCalloutView : CKOverlayView {
	CGFloat _arrowDeltaX;
	CGFloat _arrowDeltaY;
	
	CKCalloutArrowDirection _arrowDirection;
}

@property (nonatomic, assign) CKCalloutArrowDirection arrowDirection;

- (void)presentFromRect:(CGRect)rect inView:(UIView *)parentView animated:(BOOL)animated;

@end

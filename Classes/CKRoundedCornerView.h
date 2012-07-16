//
//  BackgroundView.h
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	CKRoundedCornerViewTypeNone = 0,
	CKRoundedCornerViewTypeTop,
	CKRoundedCornerViewTypeBottom,
	CKRoundedCornerViewTypeAll
} CKRoundedCornerViewType;

@interface CKRoundedCornerView : UIView {
	CKRoundedCornerViewType _corners;
	CGFloat _roundedCornerSize;
}

@property (nonatomic,assign) CKRoundedCornerViewType corners;
@property (nonatomic,assign) CGFloat roundedCornerSize;

@end

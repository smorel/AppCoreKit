//
//  CKFeedSourceViewCellController.h
//  NFB
//
//  Created by Sebastien Morel on 11-03-23.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <CloudKit/CKStandardCellController.h>
#import "CKModelObject.h"


@interface CKFeedSourceViewCellControllerStyle : CKModelObject{
}

@property (nonatomic, retain) NSString* message;
@property (nonatomic, retain) UIColor* backgroundColor;
@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, assign) UIActivityIndicatorViewStyle indicatorStyle;

+ (CKFeedSourceViewCellControllerStyle*)defaultStyle;

@end

@interface CKFeedSourceViewCellController : CKStandardCellController {
}

@end

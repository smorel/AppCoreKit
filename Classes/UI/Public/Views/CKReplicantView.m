//
//  CKReplicantView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-05.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReplicantView.h"
#import "CKStyleView.h"

@interface CKReplicantView()
@property(nonatomic,retain) UIView* view;
@property(nonatomic,assign) BOOL withoutSubviews;
@end

@implementation CKReplicantView

- (void)dealloc{
    [_view release];
    [super dealloc];
}

- (id)initWithView:(UIView*)view withoutSubviews:(BOOL)withoutSubviews{
    self = [super initWithFrame:view.bounds];
    self.backgroundColor = [UIColor clearColor];
    self.withoutSubviews = withoutSubviews;
    self.view = view;
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef gc = UIGraphicsGetCurrentContext();
    if(self.withoutSubviews){
        [self.view.layer renderInContext:gc];
        if(self.view.styleView){
            [self.view.styleView.layer renderInContext:gc];
        }
    }else{
        [self.view drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    }
}

@end

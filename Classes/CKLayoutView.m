//
//  CKLayoutView.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKLayoutView.h"

@interface CKLayoutView ()

- (void)performLayout;

@end

@implementation CKLayoutView

@dynamic subviews, bounds;
@synthesize layoutManager;

- (void)setLayoutManager:(id<CKLayoutManager>)aLayoutManager {
    if (layoutManager != aLayoutManager) {
        aLayoutManager.layoutContainer = self;
        
        [layoutManager release];
        layoutManager = [aLayoutManager retain];
        
        [self setNeedsAutomaticLayout];
    }
}

- (void)setNeedsAutomaticLayout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performLayout) object:nil]; //Perform the layout only once at the end of the runloop
    [self performSelector:@selector(performLayout) withObject:nil afterDelay:0];
}

- (void)performLayout {
    [self.layoutManager layout];
}

@end

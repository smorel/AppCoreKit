//
//  CKLayoutView.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKLayoutManager.h"

@interface CKLayoutView : UIView <CKLayoutContainer>

@property (nonatomic, retain) id <CKLayoutManager> layoutManager;

- (void)setNeedsAutomaticLayout;

@end

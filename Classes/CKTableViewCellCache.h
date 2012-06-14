//
//  CKTableViewCellCache.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-06-13.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKTableViewCellCache : NSObject

- (UIView*)reusableViewWithIdentifier:(NSString*)identifier;
- (void)setReusableView:(UIView*)view forIdentifier:(NSString*)identifier;

@end

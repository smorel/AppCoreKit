//
//  UIView+LayoutHelper.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "UIView+LayoutHelper.h"
#import "CKLayoutView.h"

@implementation UIView (LayoutHelper)

- (CGSize)preferedSize {
    if ([self isKindOfClass:[CKLayoutView class]]) {
        id <CKLayoutManager> manager = [(CKLayoutView*) self layoutManager];
        if (manager) {
            if ([manager respondsToSelector:@selector(preferedSize)])
                return manager.preferedSize;
        }
    }
    
    return self.bounds.size;
}

- (CGSize)minimumSize {
    if ([self isKindOfClass:[CKLayoutView class]]) {
        id <CKLayoutManager> manager = [(CKLayoutView*) self layoutManager];
        if (manager) {
            if ([manager respondsToSelector:@selector(minimumSize)])
                return manager.minimumSize;
        }
    }
    
    return self.preferedSize;
}

- (CGSize)maximumSize {
    if ([self isKindOfClass:[CKLayoutView class]]) {
        id <CKLayoutManager> manager = [(CKLayoutView*) self layoutManager];
        if (manager) {
            if ([manager respondsToSelector:@selector(maximumSize)])
                return manager.maximumSize;
        }
    }
    
    return self.preferedSize;
}

@end

//
//  CKCollectionViewCell.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-22.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewCell.h"

#import <objc/runtime.h>

#import "CKStyleManager.h"
#import "NSObject+Bindings.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Style.h"
#import "CKLocalization.h"
#import "CKRuntime.h"

#import "UIView+Positioning.h"
#import "CKProperty.h"
#import "NSObject+Singleton.h"
#import "CKDebug.h"
#import "UIView+Name.h"
#import "CKConfiguration.h"
#import "Layout.h"
#import "CKStyle+Parsing.h"

#import "CKVersion.h"
#import "CKResourceManager.h"

@interface CKCollectionViewCell()
@property(nonatomic,assign) BOOL hasBeenInitialized;
@end

@implementation CKCollectionViewCell

- (void)prepareForReuse{
    [super prepareForReuse];
    
    __unsafe_unretained CKCollectionViewCell* bself = self;
    
    self.contentView.invalidatedLayoutBlock = ^(NSObject<CKLayoutBoxProtocol>* box){
        UICollectionView* collectionView = [bself parentCollectionView];
        [collectionView.collectionViewLayout invalidateLayout];
    };
}

- (UICollectionView*)parentCollectionView{
    UIView* v = [self superview];
    while(v){
        if([v isKindOfClass:[UICollectionView class]]){
            return (UICollectionView*)v;
        }
        v = [v superview];
    }
    return nil;
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    return [self.contentView preferredSizeConstraintToSize:size];
}

@end

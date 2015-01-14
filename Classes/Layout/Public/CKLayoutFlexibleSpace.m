//
//  CKLayoutFlexibleSpace.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKLayoutFlexibleSpace.h"
#import "CKHorizontalBoxLayout.h"
#import "CKVerticalBoxLayout.h"
#import "CKCascadingTree.h"

@interface CKLayoutBox()
@property(nonatomic,assign,readwrite) UIView* containerLayoutView;
#ifdef LAYOUT_DEBUG_ENABLED
@property(nonatomic,assign,readwrite) UIView* debugView;
#endif

@end

@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;
- (NSObject<CKLayoutBoxProtocol>*)previousVisibleBoxFromIndex:(NSInteger)index;

@end


@implementation CKLayoutFlexibleSpace


+ (void)load{
    [CKCascadingTree registerAlias:[[self class]description] forKey:@"FlexibleSpace"];
}

- (id)init{
    self = [super init];
    
#ifdef LAYOUT_DEBUG_ENABLED
    self.debugView.backgroundColor = [UIColor greenColor];
    self.debugView.layer.borderColor = [[UIColor greenColor]CGColor];
    self.debugView.layer.borderWidth = 2;
#endif
    
    return self;
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    if([self.containerLayoutBox isKindOfClass:[CKHorizontalBoxLayout class]])
        self.lastPreferedSize = [CKLayoutBox preferredSizeConstraintToSize:CGSizeMake(size.width,1) forBox:self];
    else if([self.containerLayoutBox isKindOfClass:[CKVerticalBoxLayout class]])
        self.lastPreferedSize = [CKLayoutBox preferredSizeConstraintToSize:CGSizeMake(1,size.height) forBox:self];
    
    return self.lastPreferedSize;
}

- (void)performLayoutWithFrame:(CGRect)theframe{
    [self setBoxFrameTakingCareOfTransform:theframe];
    
#ifdef LAYOUT_DEBUG_ENABLED
    self.debugView.frame = theframe;
#endif
}
     
@end

//
//  CKSegmentedControl.h
//  customNav
//
//  Created by Sebastien Morel on 11-10-12.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CKSegmentedControlButtonPosition{
    CKSegmentedControlButtonPositionFirst  = 1 << 0,
    CKSegmentedControlButtonPositionMiddle = 1 << 1,
    CKSegmentedControlButtonPositionLast   = 1 << 2,
    CKSegmentedControlButtonPositionAlone  = 1 << 3
}CKSegmentedControlButtonPosition;

@interface CKSegmentedControlButton : UIButton 
@property(nonatomic,assign,readonly)CKSegmentedControlButtonPosition position;
@end

@interface CKSegmentedControl : UIControl 

#pragma mark UISegmentedControl API

@property(nonatomic,assign)BOOL momentary;
@property(nonatomic,readonly)NSInteger numberOfSegments;
@property(nonatomic,assign)NSInteger selectedSegmentIndex;

//An array of NSString objects (for segment titles) or UIImage objects (for segment images).
- (id)initWithItems:(NSArray *)items;

- (CGSize)contentOffsetForSegmentAtIndex:(NSUInteger)segment;
- (void)setContentOffset:(CGSize)offset forSegmentAtIndex:(NSUInteger)segment;
- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment;
- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;
- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (CKSegmentedControlButton*)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment;
- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment;
- (void)removeAllSegments;
- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;
- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment;
- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment;

#pragma mark CKSegmentedControl API

- (CKSegmentedControlButton*)segmentAtIndex:(NSInteger)index;
- (void)setSelectedSegment:(CKSegmentedControlButton*)segment;

- (CKSegmentedControlButton*)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated action:(void(^)())action;
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated action:(void(^)())action;
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title image:(UIImage*)image atIndex:(NSUInteger)segment animated:(BOOL)animated action:(void(^)())action;

- (CKSegmentedControlButton*)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated target:(id)target action:(SEL)action;
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated target:(id)target action:(SEL)action;
- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title image:(UIImage*)image atIndex:(NSUInteger)segment animated:(BOOL)animated target:(id)target action:(SEL)action;

@end

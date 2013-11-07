//
//  CKCollectionViewMorphableLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-18.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewLayout.h"

@class CKCollectionViewMorphableLayout;

/**
 */
@protocol CKCollectionViewMorphableLayoutDelegate <NSObject>

/**
 */
- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout willMorphFormRatio:(CGFloat)ratio toRatio:(CGFloat)toRatio;

/**
 */
- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout isMorphingWithRatio:(CGFloat)ratio velocity:(CGFloat)velocity;

/**
 */
- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout didMorphFormRatio:(CGFloat)ratio toRatio:(CGFloat)toRatio;

@end




/**
 */
@interface CKCollectionViewMorphableLayout : CKCollectionViewLayout

/**
 */
@property(nonatomic,assign) id<CKCollectionViewMorphableLayoutDelegate> delegate;

/**
 */
@property(nonatomic,retain,readonly) NSArray* layouts;

/**
 */
@property(nonatomic,readonly) CKCollectionViewLayout* currentLayout;

/**
 */
@property(nonatomic,readonly) NSInteger currentLayoutIndex;

/**
 */
+ (CKCollectionViewMorphableLayout*)morphableLayoutWithLayouts:(NSArray*)layouts;

/**
 */
@property(nonatomic,assign)          CGFloat morphRatio;

/**
 */
@property(nonatomic,assign)          BOOL isMorphing;

/**
 */
@property(nonatomic,copy)            void(^didReachLayoutBlock)(CKCollectionViewMorphableLayout* morphableLayout, CKCollectionViewLayout* layout, NSIndexPath* centerItem);

/**
 */
@property(nonatomic,copy)            void(^isMorphingLayoutBlock)(CKCollectionViewMorphableLayout* morphableLayout, BOOL morphing, NSIndexPath* indexPathForViewOfInterest);


/**
 */
- (void)morphToRatio:(CGFloat)ratio centerItem:(NSIndexPath*)indexPath animated:(BOOL)animated;


/**
 */
@property(nonatomic,retain,readonly) UIPinchGestureRecognizer* pinchGestureRecognizer;

/** default value is 300
 */
@property(nonatomic,assign)          CGFloat pinchMaximumDistance;

/** TODO Adds interactiveViewPinchEnabled to fully control the pinched view while transiting between layouts (rotation/translation/scale)
 */

@property(nonatomic,assign) BOOL toggleSlowAnimations;

@end




/**
 */
@interface UICollectionViewCell (CKCollectionViewMorphableLayout)

/**
 */
- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout didUpdateRatio:(CGFloat)morphRatio;


/*TODO : adds spring anim for transitions !
*/

@end
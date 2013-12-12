//
//  CKCollectionViewMorphableLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-18.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewMorphableLayout.h"
#import "CKAnimationManager.h"
#import "CKAnimationInterpolator.h"
#import "UIGestureRecognizer+BlockBasedInterface.h"

CGRect CGRectInterpolate(CGRect from, CGRect to, CGFloat ratio){
    CGFloat x = from.origin.x + ((to.origin.x - from.origin.x) * ratio);
    CGFloat y = from.origin.y + ((to.origin.y - from.origin.y) * ratio);
    CGFloat width = from.size.width + ((to.size.width - from.size.width) * ratio);
    CGFloat height = from.size.height + ((to.size.height - from.size.height) * ratio);
    
    return CGRectIntegral(CGRectMake(x,y,width,height));
}


CGSize CGSizeInterpolate(CGSize from, CGSize to, CGFloat ratio){
    CGFloat width = from.width + ((to.width - from.width) * ratio);
    CGFloat height = from.height + ((to.height - from.height) * ratio);
    
    return CGSizeMake(ceilf(width),ceilf(height));
}

CGPoint CGPointInterpolate(CGPoint from, CGPoint to, CGFloat ratio){
    CGFloat x = from.x + ((to.x - from.x) * ratio);
    CGFloat y = from.y + ((to.y - from.y) * ratio);
    
    return CGPointMake(ceilf(x),ceilf(y));
}

@interface CKCollectionViewMorphableLayout()
@property(nonatomic,retain,readwrite) UIPinchGestureRecognizer* pinchGestureRecognizer;
@property(nonatomic,retain) NSIndexPath* centralIndexPath;
@property(nonatomic,assign) CGPoint startMorphContentOffset;
@property(nonatomic,assign) CGFloat startMorphRatio;
@property(nonatomic,assign) CGFloat previousMorphRatio;
@property(nonatomic,retain,readwrite) CKAnimationManager* animationManager;
@property(nonatomic,retain,readwrite) NSArray* layouts;
@property(nonatomic,retain,readwrite) NSIndexPath* viewOfInterest;
@property(nonatomic,assign) CGFloat startMorphRatioForDelegate;
@property(nonatomic,assign) CGFloat endMorphRatioForDelegate;
@end

@implementation CKCollectionViewMorphableLayout

- (void)dealloc{
    if(self.animationManager){
        [self.animationManager unregisterFromScreen];
    }
    
    if(self.pinchGestureRecognizer){
        [self.pinchGestureRecognizer.view removeGestureRecognizer:self.pinchGestureRecognizer];
    }
    
    [_layouts release];
    [_didReachLayoutBlock release];
    [_isMorphingLayoutBlock release];
    [_pinchGestureRecognizer release];
    [_centralIndexPath release];
    [_animationManager release];
    [_viewOfInterest release];
    
    [super dealloc];
}

+ (CKCollectionViewMorphableLayout*)morphableLayoutWithLayouts:(NSArray*)layouts{
    CKCollectionViewMorphableLayout* m = [[[CKCollectionViewMorphableLayout alloc]init]autorelease];
    m.layouts = layouts;
    for(CKCollectionViewLayout* l in layouts){
        l.parentCollectionViewLayout = m;
    }
    return m;
}

- (id)init{
    self = [super init];
    self.pinchMaximumDistance = 300;
    return self;
}

- (CGRect)frameForViewAtIndexPath:(NSIndexPath*)indexPath{
    NSInteger first = floorf(self.morphRatio);
    CGFloat ratioDiff = self.morphRatio - first;
    if(ratioDiff == 0){
        CKCollectionViewLayout* firstLayout = [self.layouts objectAtIndex:first];
        return [firstLayout frameForViewAtIndexPath:indexPath];
    }
    
    if(ratioDiff == 0 && first > 0){ first--; }
    
    NSInteger second = ceilf(self.morphRatio);
    if(first == second){ if(first == self.layouts.count - 1) { first--; } else { second++; } }
    
    CKCollectionViewLayout* firstLayout = [self.layouts objectAtIndex:first];
    CKCollectionViewLayout* secondLayout = [self.layouts objectAtIndex:second];
    CGRect firstFrame  = [firstLayout frameForViewAtIndexPath:indexPath];
    CGRect secondFrame = [secondLayout frameForViewAtIndexPath:indexPath];
    return CGRectInterpolate(firstFrame,secondFrame,self.morphRatio - first);
}

- (CGSize)collectionViewContentSize{
    NSInteger first = floorf(self.morphRatio);
    CGFloat ratioDiff = self.morphRatio - first;
    if(ratioDiff == 0){
        CKCollectionViewLayout* firstLayout = [self.layouts objectAtIndex:first];
        return [firstLayout collectionViewContentSize];
    }
    
    
    if(ratioDiff == 0 && first > 0){ first--; }
    
    NSInteger second = ceilf(self.morphRatio);
    if(first == second){ if(first == self.layouts.count - 1) { first--; } else { second++; } }
    
    CKCollectionViewLayout* firstLayout = [self.layouts objectAtIndex:first];
    CKCollectionViewLayout* secondLayout = [self.layouts objectAtIndex:second];
    CGSize firstSize = [firstLayout collectionViewContentSize];
    CGSize secondSize = [secondLayout collectionViewContentSize];
    return CGSizeInterpolate(firstSize,secondSize,self.morphRatio - first);
}

- (CGPoint)contentOffsetForMorphRatio:(CGFloat)ratio{
    NSInteger first = floorf(ratio);
    CGFloat ratioDiff = ratio - first;
    if(ratioDiff == 0){
        CKCollectionViewLayout* firstLayout = [self.layouts objectAtIndex:first];
        return [firstLayout contentOffsetForViewAtIndexPath:self.centralIndexPath];
    }
    
    
    if(self.previousMorphRatio < ratio && ratioDiff == 0 && first > 0){ first--; }
    
    NSInteger second = ceilf(ratio);
    if(first == second){ if(first == self.layouts.count - 1) { first--; } else { second++; } }
    
    CKCollectionViewLayout* firstLayout = [self.layouts objectAtIndex:first];
    CKCollectionViewLayout* secondLayout = [self.layouts objectAtIndex:second];
    
    if(ratio > self.startMorphRatio){
        NSInteger floorStartMorphRatio = floorf(ratio);
        
        CGPoint firstOffset = (ratio > (floorStartMorphRatio + 1)) ? [firstLayout contentOffsetForViewAtIndexPath:self.centralIndexPath] : self.startMorphContentOffset;
        CGPoint secondOffset = [secondLayout contentOffsetForViewAtIndexPath:self.centralIndexPath];
        return CGPointInterpolate(firstOffset,secondOffset,(ratio /*- self.startMorphRatio)*/ - first));
    }else{
        NSInteger ceilStartMorphRatio = ceilf(self.startMorphRatio);
        
        CGPoint secondOffset = (ratio < (ceilStartMorphRatio - 1)) ? [secondLayout contentOffsetForViewAtIndexPath:self.centralIndexPath] : self.startMorphContentOffset;
        CGPoint firstOffset = [firstLayout contentOffsetForViewAtIndexPath:self.centralIndexPath];
        return CGPointInterpolate(secondOffset,firstOffset,/*(self.startMorphRatio - ratio) - second*/ second - ratio);
    }
}

- (void)setMorphRatio:(CGFloat)theRatio{
    if(_morphRatio == theRatio)
        return;
    
    _morphRatio = theRatio;
    
    self.collectionView.contentOffset = [self contentOffsetForMorphRatio:theRatio];
    
    NSArray * visibleCells = [self.collectionView visibleCells];
    for(UICollectionViewCell* cell in visibleCells){
        [cell morphableLayout:self didUpdateRatio:self.morphRatio];
    }
    
    if(self.didReachLayoutBlock){
        NSInteger index = floorf(self.morphRatio);
        CGFloat diff = self.morphRatio - index;
        if(diff == 0){
            self.didReachLayoutBlock(self,[self.layouts objectAtIndex:index],[self indexPathForViewOfInterest]);
        }
    }
    
    if(self.isMorphingLayoutBlock){
        NSInteger index = floorf(self.morphRatio);
        CGFloat diff = self.morphRatio - index;
        
        NSInteger previousIndex = floorf(self.previousMorphRatio);
        CGFloat previousDiff = self.previousMorphRatio - previousIndex;
        
        if((previousDiff == 0) && diff != 0){
            self.isMorphingLayoutBlock(self,YES,[self indexPathForViewOfInterest]);
        }else if((diff == 0) && previousDiff != 0){
            self.isMorphingLayoutBlock(self,NO,[self indexPathForViewOfInterest]);
        }
    }
    
    CGFloat velocity = theRatio - self.previousMorphRatio;
    self.previousMorphRatio = theRatio;
    
    if(self.isMorphing && self.delegate){
        [self.delegate morphableLayout:self isMorphingWithRatio:self.morphRatio velocity:velocity];
    }
    
    [self invalidateLayout];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    CKCollectionViewLayout* l = [self currentLayout];
    return [l targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset{
    CKCollectionViewLayout* l = [self currentLayout];
    return [l targetContentOffsetForProposedContentOffset:proposedContentOffset];
}

- (NSIndexPath*)indexPathForViewOfInterest{
    if(self.viewOfInterest)
        return self.viewOfInterest;
    
    if(self.collectionView.indexPathsForSelectedItems.count > 0){
        return [self.collectionView.indexPathsForSelectedItems objectAtIndex:0];
    }
    
    NSInteger index = floorf(self.morphRatio);
    CGFloat diff = self.morphRatio - index;
    
    CKCollectionViewLayout* l = nil;
    if(diff < 0.5){
        l = [self.layouts objectAtIndex:index];
    }else{
        l = [self.layouts objectAtIndex:index+1];
    }
    return [l indexPathForViewOfInterest];
}

- (CGPoint)contentOffsetForViewAtIndexPath:(NSIndexPath*)indexPath{
    CKCollectionViewLayout* l = [self currentLayout];
    return [l contentOffsetForViewAtIndexPath:indexPath];
}

//For pinch gesture management


- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems{
}

- (void)prepareLayout{
    if(!self.animationManager){
        if(self.collectionView.window){
            self.animationManager = [[[CKAnimationManager alloc]init]autorelease];
            [self.animationManager registerInScreen:self.collectionView.window.screen];
        }
    }
    
    if(!self.pinchGestureRecognizer){
        [self setupPinchGesture];
    }
    
    for(CKCollectionViewLayout* l in self.layouts){
        [l prepareLayout];
    }
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath{
    NSInteger first = floorf(self.morphRatio);
    CGFloat ratioDiff = self.morphRatio - first;
    if(ratioDiff == 0 && first > 0){ first--; }
    
    NSInteger second = ceilf(self.morphRatio);
    if(first == second){ if(first == self.layouts.count - 1) { first--; } else { second++; } }
    
    CKCollectionViewLayout* firstLayout = [self.layouts objectAtIndex:first];
    CKCollectionViewLayout* secondLayout = [self.layouts objectAtIndex:second];
    
    UICollectionViewLayoutAttributes* attributeFirst  = [firstLayout layoutAttributesForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes* attributeSecond = [secondLayout layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect frame =  CGRectInterpolate(attributeFirst.frame,attributeSecond.frame,self.morphRatio - first);
    
    UICollectionViewLayoutAttributes *attributes =  [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = frame;
    attributes.zIndex = MAX(attributeFirst.zIndex,attributeSecond.zIndex);
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray* array = [NSMutableArray array];
    
    NSInteger first = floorf(self.morphRatio);
    CGFloat ratioDiff = self.morphRatio - first;
    if(ratioDiff == 0 && first > 0){ first--; }
    
    NSInteger second = ceilf(self.morphRatio);
    if(first == second){ if(first == self.layouts.count - 1) { first--; } else { second++; } }
    
    CKCollectionViewLayout* firstLayout = [self.layouts objectAtIndex:first];
    CKCollectionViewLayout* secondLayout = [self.layouts objectAtIndex:second];

    
    NSInteger numberOfSections = 1;
    if([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]){
        numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    }
    
    NSIndexPath* indexPathOfInterest = [self indexPathForViewOfInterest];
    for(int section = 0; section < numberOfSections; ++section){
        for(int item =0;item<[self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];++item){
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes* attributeFirst  = [firstLayout layoutAttributesForItemAtIndexPath:indexPath];
            UICollectionViewLayoutAttributes* attributeSecond = [secondLayout layoutAttributesForItemAtIndexPath:indexPath];
            
            CGRect frame =  CGRectInterpolate(attributeFirst.frame,attributeSecond.frame,self.morphRatio - first);
            if(CGRectIntersectsRect(frame, rect)){
                UICollectionViewLayoutAttributes *attributes =  [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attributes.frame = frame;
                attributes.zIndex = [indexPathOfInterest isEqual:indexPath] ? 10 : 0;// 999999 - [self distanceBetweenIndexPath:indexPathOfInterest target:indexPath];
                [array addObject:attributes];
            }
        }
    }
    return array;
}


- (void)startTransitionUsingCentralPoint:(CGPoint)centralPoint{
    self.centralIndexPath = [self indexPathForViewAtPoint:centralPoint];
    self.startMorphContentOffset = self.collectionView.contentOffset;
    self.startMorphRatio = self.morphRatio;
}


- (void)morphToRatio:(CGFloat)ratio centerItem:(NSIndexPath*)indexPath animated:(BOOL)animated completion:(void(^)())completion{
    if(indexPath){
        CGRect frame = [self frameForViewAtIndexPath:indexPath];
        CGPoint center = CGPointMake(frame.origin.x + (frame.size.width / 2),frame.origin.y + (frame.size.height / 2));
        
        [self startTransitionUsingCentralPoint:center];
    }else{
        CGPoint center = CGPointMake(self.collectionView.contentOffset.x + (self.collectionView.bounds.size.width / 2),self.collectionView.contentOffset.y + (self.collectionView.bounds.size.height / 2));
        [self startTransitionUsingCentralPoint:center];
    }
    
    [self morphToRatio:ratio centerItem:indexPath animationDuration:animated ? .3 : 0 completion:completion];
}


- (void)morphToRatio:(CGFloat)ratio centerItem:(NSIndexPath*)indexPath animationDuration:(NSTimeInterval)animationDuration  completion:(void(^)())completion{
    if(!self.isMorphing){
        self.isMorphing = YES;
        self.startMorphRatioForDelegate = self.morphRatio;
        self.endMorphRatioForDelegate = ratio;
        if(self.delegate){
            [self.delegate morphableLayout:self willMorphFormRatio:self.morphRatio toRatio:ratio];
        }
    }
    
    if(!self.viewOfInterest){
        if(self.collectionView.indexPathsForSelectedItems.count > 0){
            self.viewOfInterest = [self.collectionView.indexPathsForSelectedItems objectAtIndex:0];
        }else{
            self.viewOfInterest = [self indexPathForViewOfInterest];
        }
    }
    
     //Stop Scrolling
     [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y) animated:NO];
     
     //TODO : deactivate pinch when animating
    // self.pinchGestureRecognizer.enabled = NO;
     
     //[[VARApplication sharedInstance]setSearchSelectedItem:focus ? (floorf(item) + 0.5) : -1];
    if(animationDuration != 0){
        CKAnimationPropertyInterpolator* interpolator = [CKAnimationPropertyInterpolator animationWithObject:self keyPath:@"morphRatio"];
        interpolator.values = @[[NSNumber numberWithFloat:self.morphRatio],[NSNumber numberWithFloat:ratio]];
        interpolator.duration = animationDuration * (self.toggleSlowAnimations ? 10 : 1);
        interpolator.options = CKAnimationOptionForwards;
        interpolator.eventBlock = ^(CKAnimation* animation, CKAnimationEvents event){
            if(event == CKAnimationEventEnd){
                self.viewOfInterest = nil;
                self.isMorphing = NO;
                
                if(self.delegate){
                    [self.delegate morphableLayout:self didMorphFormRatio:self.startMorphRatioForDelegate toRatio:self.endMorphRatioForDelegate];
                }
                
                if(completion){
                    completion();
                }
            }
        };
        [interpolator startInManager:self.animationManager];
    }else{
        self.morphRatio = ratio;
        
        self.viewOfInterest = nil;
        self.isMorphing = NO;
        
        if(self.delegate){
            [self.delegate morphableLayout:self didMorphFormRatio:self.startMorphRatioForDelegate toRatio:self.endMorphRatioForDelegate];
        }
        
        if(completion){
            completion();
        }
    }
}


- (void)setupPinchGesture{
    __unsafe_unretained CKCollectionViewMorphableLayout* bself =  self;
    
    __block CGFloat startDistance = 0;
    __block CGFloat startRatio = 0;
    __block CGFloat nextTargetRatio = 0;
    __block CGFloat previousTargetRatio = 0;
    __block CGFloat lastPinchDirection = 0;
    __block BOOL justStated = YES;
    __block NSIndexPath* focusItem = 0;
    __block CGFloat floorStartRatio = 0;
    __block UICollectionViewCell* startCell = 0;
    
    self.pinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc]initWithBlock:^(UIGestureRecognizer *gestureRecognizer) {
        
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded
           || gestureRecognizer.state == UIGestureRecognizerStateCancelled){
            if(startRatio == bself.morphRatio){
                bself.isMorphing = NO;
                return;
            }
            
            CGFloat velocity = [(UIPinchGestureRecognizer*)gestureRecognizer velocity];
            
            CGFloat floorRatio = floorf(bself.morphRatio);
            CGFloat diff = bself.morphRatio - floorRatio;
            
            CGFloat targetOffset;
            if(fabs(velocity) > 2){
                targetOffset = velocity > 0 ? 1  : 0;
            }else{
                targetOffset = (diff > 0.5) ? 1  : 0;
            }
            
            CGFloat target = (floorRatio+targetOffset);
            target = MAX(floorStartRatio,MIN(floorStartRatio+1, target));
            
            CGFloat distanceRatio = fabs(bself.morphRatio - target);
            CGFloat duration = distanceRatio  * 0.25;
            
            bself.startMorphRatioForDelegate = floorRatio;
            bself.endMorphRatioForDelegate = target;
            
            [bself morphToRatio:target centerItem:focusItem animationDuration:duration completion:nil];
            
            bself.viewOfInterest = nil;
            lastPinchDirection = 0;
            
            return;
        }
        
        if ([gestureRecognizer numberOfTouches] != 2){
            return;
        }
        
        // Get the pinch points.
        CGPoint p1 = [gestureRecognizer locationOfTouch:0 inView:[bself collectionView]];
        CGPoint p2 = [gestureRecognizer locationOfTouch:1 inView:[bself collectionView]];
        
        // Compute the new spread distance.
        CGFloat xd = p1.x - p2.x;
        CGFloat yd = p1.y - p2.y;
        CGFloat distance = sqrt(xd*xd + yd*yd);
        
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
            [bself.animationManager stopAllAnimations];
            justStated = YES;
            
            startDistance = distance / bself.pinchMaximumDistance;
            startRatio = bself.morphRatio;
            
            CGPoint center = CGPointMake((p1.x + p2.x ) / 2,(p1.y + p2.y ) / 2);
            [bself startTransitionUsingCentralPoint:center];
            
            focusItem = [bself indexPathForViewAtPoint:center];
            bself.viewOfInterest = focusItem;
            
            startCell = [[bself collectionView]cellForItemAtIndexPath:focusItem];
            
            //Force to interupt scrollng
            [[bself collectionView] setContentOffset:CGPointMake([bself collectionView].contentOffset.x, [bself collectionView].contentOffset.y) animated:NO];
            
            //Calls willMorphFrom : to :
            
        }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
            
            CGFloat velocity = [(UIPinchGestureRecognizer*)gestureRecognizer velocity];
            
            if(justStated){
                floorStartRatio = floorf(startRatio);
                if(floorStartRatio == startRatio){
                    floorStartRatio += velocity >= 0 ? 0 : -1;
                }
                if(floorStartRatio < 0) { floorStartRatio = 0; }
                if(floorStartRatio >= bself.layouts.count - 1){  floorStartRatio = bself.layouts.count - 2; }
            }
            
            CGFloat ratio =  (distance / bself.pinchMaximumDistance) - startDistance;
            CGFloat newRatio = MAX(floorStartRatio,MIN(floorStartRatio+1, startRatio + ratio));
            
            //using lastPinchDirection
            //Calls didlMorphFrom : to : if changing direction
            //Calls willMorphFrom : to : if needed
            
            
            CGFloat targetOffset = velocity >= 0 ? 1  : 0;
            CGFloat floorRatio = floorf(newRatio);
            CGFloat target = (floorRatio+targetOffset);
            target = MAX(0,MIN(target,bself.layouts.count - 1));
            
            //if(fabs(velocity) > 2){
            lastPinchDirection = newRatio - bself.morphRatio;
            // }
            
            bself.startMorphRatioForDelegate = startRatio;
            bself.endMorphRatioForDelegate = target;
            bself.isMorphing = (newRatio != startRatio);
            
            if(justStated && bself.delegate){
                if(startRatio != target){
                    [bself.delegate morphableLayout:bself willMorphFormRatio:startRatio toRatio:target];
                    previousTargetRatio = startRatio;
                    justStated = NO;
                }
            }else if(nextTargetRatio != target && bself.delegate){
                [bself.delegate morphableLayout:bself didMorphFormRatio:previousTargetRatio toRatio:nextTargetRatio];
                previousTargetRatio = nextTargetRatio;
                [bself.delegate morphableLayout:bself willMorphFormRatio:previousTargetRatio toRatio:target];
            }
            
            nextTargetRatio = target;
            
            bself.morphRatio = newRatio;
            
        }
        
    } shouldBeginBlock:^BOOL(UIGestureRecognizer *gestureRecognizer) {
        return gestureRecognizer.numberOfTouches == 2;
    }]autorelease];
    
    
    [[self collectionView] addGestureRecognizer:self.pinchGestureRecognizer];
    [[[self collectionView]panGestureRecognizer]requireGestureRecognizerToFail:self.pinchGestureRecognizer];
    [[self collectionView]panGestureRecognizer].maximumNumberOfTouches = 1;
}

- (CKCollectionViewLayout*)currentLayout{
    return [self.layouts objectAtIndex:[self currentLayoutIndex]];
}

- (NSInteger)currentLayoutIndex{
    NSInteger index = floorf(self.morphRatio);
    CGFloat diff = self.morphRatio - index;
    if(diff > 0.5){
        index++;
    }
    return index;
}

/*
- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds{
    CKCollectionViewLayout* l = [self currentLayout];
    [l prepareForAnimatedBoundsChange:oldBounds];
}

- (void)finalizeAnimatedBoundsChange{
    CKCollectionViewLayout* l = [self currentLayout];
    [l finalizeAnimatedBoundsChange];
}
*/

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return NO;
}

/*
- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context{
    CKCollectionViewLayout* l = [self currentLayout];
    [l invalidateLayoutWithContext:context];
}*/

@end


@implementation UICollectionViewCell (CKCollectionViewMorphableLayout)

- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout didUpdateRatio:(CGFloat)morphRatio{
    
}

@end

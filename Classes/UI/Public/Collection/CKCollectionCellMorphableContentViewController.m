 //
//  CKCollectionCellMorphableContentViewController.m
//  VARLab
//
//  Created by Sebastien Morel on 2013-10-24.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionCellMorphableContentViewController.h"
#import "CKCollectionViewMorphableLayout.h"


@interface CKCollectionViewMorphableLayout()

- (CGPoint)contentOffsetForMorphRatio:(CGFloat)ratio;

@end

@interface CKCollectionCellMorphableContentViewControllerTransition()

@property(nonatomic,assign,readwrite) CKCollectionCellContentViewController* contentViewController;
@property(nonatomic,assign,readwrite) NSInteger contentViewControllerIndex;
@property(nonatomic,assign,readwrite) CGRect frame;
@property(nonatomic,assign,readwrite) UIView* view;
@property(nonatomic,assign,readwrite) BOOL isPerformingTransition;
@property(nonatomic,assign,readwrite) BOOL isVisible;
@property(nonatomic,assign,readwrite) BOOL willBeVisible;
@property(nonatomic,assign,readwrite) BOOL isTarget;

@end

@implementation CKCollectionCellMorphableContentViewControllerTransition

- (void)startTransitionForContentViewController:(CKCollectionCellContentViewController*)c
                                          index:(NSInteger)index
                                      isVisible:(BOOL)isVisible
                                  willBeVisible:(BOOL)willBeVisible
                                  isTarget:(BOOL)isTarget
                                      withFrame:(CGRect)f
                                          inView:(UIView*)view{
    self.contentViewController = c;
    self.frame = f;
    self.isVisible = isVisible;
    self.willBeVisible = willBeVisible;
    self.isTarget = isTarget;
    self.view = view;
    self.isPerformingTransition = YES;
    self.contentViewControllerIndex = index;
    
    [self startTransition];
}

- (void)startTransition{
    
}

- (void)performTransitionWithRatio:(CGFloat)ratio velocity:(CGFloat)velocity{
}

- (void)endTransition{
    self.isPerformingTransition = NO;
    self.contentViewController = nil;
    self.view = nil;
}

@end



@interface CKCollectionCellContentViewController ()
@property(nonatomic,assign,readwrite) CKCollectionCellController* collectionCellController;
@property(nonatomic,retain) UIView* reusableView;
@end


@interface CKCollectionCellMorphableContentViewController ()
@property(nonatomic,retain,readwrite) NSArray* contentViewControllers;
@property(nonatomic,retain,readwrite) NSDictionary* contentViewControllerToViewIndex;

@property(nonatomic,retain,readwrite) CKCollectionCellContentViewController* transitionFromContentViewController;
@property(nonatomic,retain,readwrite) CKCollectionCellContentViewController* transitionToContentViewController;

@end

@implementation CKCollectionCellMorphableContentViewController

- (id)initWithContentViewControllers:(NSArray*)theContentViewControllers{
    self = [super init];
    
    self.contentViewControllers = theContentViewControllers;
    
    //This is done to manage the fact that the same instance of CKCollectionCellContentViewController
    //can be used at several indexes in contentViewControllers
    NSMutableDictionary* indexes = [NSMutableDictionary dictionary];
    NSInteger i =0;
    for(CKCollectionCellContentViewController* contentViewController in self.contentViewControllers){
        NSValue* v = [NSValue valueWithNonretainedObject:contentViewController];
        NSNumber* index = [indexes objectForKey:v];
        if(!index){
            [indexes setObject:[NSNumber numberWithInteger:i] forKey:v];
            ++i;
        }
    }
    
    self.contentViewControllerToViewIndex = indexes;
    return self;
}



- (void)setCollectionCellController:(CKCollectionCellController *)collectionCellController{
    [super setCollectionCellController:collectionCellController];
    for(CKCollectionCellContentViewController* contentViewController in self.contentViewControllers){
        [contentViewController setCollectionCellController:collectionCellController];
    }
}

- (CGFloat)currentMorphRatio{
    if([self.contentView isKindOfClass:[UICollectionView class]]){
        id layout = [(UICollectionView*)self.contentView collectionViewLayout];
        if([layout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
            CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)layout;
            return morphableLayout.morphRatio;
        }
    }
    return 0.0f;
}

- (BOOL)isMorphing{
    if([self.contentView isKindOfClass:[UICollectionView class]]){
        id layout = [(UICollectionView*)self.contentView collectionViewLayout];
        if([layout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
            CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)layout;
            return morphableLayout.isMorphing;
        }
    }
    return NO;
}

- (NSInteger)currentLayoutIndex{
    if([self.contentView isKindOfClass:[UICollectionView class]]){
        id layout = [(UICollectionView*)self.contentView collectionViewLayout];
        if([layout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
            CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)layout;
            return morphableLayout.currentLayoutIndex;
        }
    }
    return 0;
}

- (CGRect)frameForLayoutAtIndex:(NSInteger)index{
    if([self.contentView isKindOfClass:[UICollectionView class]]){
        CKCollectionViewLayout* layout = (CKCollectionViewLayout*)[(UICollectionView*)self.contentView collectionViewLayout];
        if([layout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
            CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)layout;
            CKCollectionViewLayout* layoutAtIndex = [morphableLayout.layouts objectAtIndex:index];
            return [layoutAtIndex frameForViewAtIndexPath:self.indexPath];
        }else{
            return [layout frameForViewAtIndexPath:self.indexPath];
        }
    }
    return CGRectMake(0,0,0,0);
}

- (CKCollectionCellContentViewController*)currentContentViewController{
    NSInteger index = MIN([self currentLayoutIndex],self.contentViewControllers.count - 1);
    return [self.contentViewControllers objectAtIndex:index];
}

- (BOOL)willBeVisibleInLayoutAtIndex:(NSInteger)index{
    if([self.contentView isKindOfClass:[UICollectionView class]]){
        CKCollectionViewLayout* layout = (CKCollectionViewLayout*)[(UICollectionView*)self.contentView collectionViewLayout];
        if([layout isKindOfClass:[CKCollectionViewMorphableLayout class]]){
            CKCollectionViewMorphableLayout* morphableLayout = (CKCollectionViewMorphableLayout*)layout;
            CKCollectionViewLayout* layoutAtIndex = [morphableLayout.layouts objectAtIndex:index];
            
            CGRect frame = [layoutAtIndex frameForViewAtIndexPath:self.indexPath];
            CGPoint offset = [morphableLayout contentOffsetForMorphRatio:index];
            
            CGRect visibleArea = CGRectMake(offset.x,offset.y,self.contentView.frame.size.width,self.contentView.frame.size.height);
            return CGRectIntersectsRect(frame, visibleArea);
        }
    }
    return NO;
}

- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout willMorphFormRatio:(CGFloat)ratio toRatio:(CGFloat)toRatio{
    NSInteger floorFrom = floorf(ratio);
    NSInteger floorToRatio = floorf(toRatio);
    
    
    NSInteger fromIndex = MIN(floorFrom,self.contentViewControllers.count - 1);
    NSInteger toIndex = MIN(floorToRatio,self.contentViewControllers.count - 1);
    
    CGRect fromFrame = [self frameForLayoutAtIndex:fromIndex];
    CGRect toFrame = [self frameForLayoutAtIndex:toIndex];
    
    
    self.transitionFromContentViewController = [self.contentViewControllers objectAtIndex:fromIndex];
    self.transitionToContentViewController   = [self.contentViewControllers objectAtIndex:toIndex];
    
    [self.transitionFromContentViewController viewWillDisappear:YES];
    [self.transitionToContentViewController viewWillAppear:YES];
    
    BOOL isVisible = [self willBeVisibleInLayoutAtIndex:fromIndex];
    BOOL willBeVisible = [self willBeVisibleInLayoutAtIndex:toIndex];
    
    self.transitionFromContentViewController.view.hidden = NO;
    self.transitionToContentViewController.view.hidden = NO;
    
    if(ratio <= toRatio){
        [self.transitionFromContentViewController.transition startTransitionForContentViewController:self.transitionFromContentViewController
                                                                                               index:fromIndex
                                                                                           isVisible:isVisible
                                                                                       willBeVisible:willBeVisible
                                                                                            isTarget:NO
                                                                                           withFrame:fromFrame
                                                                                              inView:self.view];
        
        [self.transitionToContentViewController.transition startTransitionForContentViewController:self.transitionToContentViewController
                                                                                             index:toIndex
                                                                                         isVisible:isVisible
                                                                                     willBeVisible:willBeVisible
                                                                                          isTarget:YES
                                                                                         withFrame:toFrame inView:self.view];
    }else{
        [self.transitionToContentViewController.transition startTransitionForContentViewController:self.transitionToContentViewController
                                                                                             index:toIndex
                                                                                         isVisible:isVisible
                                                                                     willBeVisible:willBeVisible
                                                                                          isTarget:YES
                                                                                         withFrame:toFrame inView:self.view];
        
        [self.transitionFromContentViewController.transition startTransitionForContentViewController:self.transitionFromContentViewController
                                                                                               index:fromIndex
                                                                                           isVisible:isVisible
                                                                                       willBeVisible:willBeVisible
                                                                                            isTarget:NO
                                                                                           withFrame:fromFrame
                                                                                              inView:self.view];
    }
}

- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout didMorphFormRatio:(CGFloat)ratio toRatio:(CGFloat)toRatio{

    if(self.transitionFromContentViewController){
        [self.transitionFromContentViewController viewDidDisappear:YES];
        [self.transitionFromContentViewController.transition endTransition];
        self.transitionFromContentViewController = nil;
    }
    
    if(self.transitionToContentViewController){
        [self.transitionToContentViewController viewDidAppear:YES];
        [self.transitionToContentViewController.transition endTransition];
        self.transitionToContentViewController = nil;
    }
    
    //Unique instances of content view controllers
    CKCollectionCellContentViewController* current = [self currentContentViewController];
    NSSet* set = [NSSet setWithArray:self.contentViewControllers];
    for(CKCollectionCellContentViewController* contentViewController in set){
        UIView* contentViewControllerView = [self contentViewForContentViewController:contentViewController];
        contentViewControllerView.hidden = (current != contentViewController);
        contentViewControllerView.alpha = 1;
    }
}

- (void)morphableLayout:(CKCollectionViewMorphableLayout*)morphableLayout isMorphingWithRatio:(CGFloat)ratio velocity:(CGFloat)velocity{
    NSInteger floorRatio = floorf(ratio);
    CGFloat diff = fabs(ratio - floorRatio);

    
    if(self.transitionFromContentViewController){
        [self.transitionFromContentViewController.transition performTransitionWithRatio:diff velocity:velocity];
    }
    
    if(self.transitionToContentViewController){
        [self.transitionToContentViewController.transition performTransitionWithRatio:diff velocity:velocity];
    }
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    return [super preferredSizeConstraintToSize:size];
}

- (UIView*)contentViewForContentViewController:(CKCollectionCellContentViewController*)contentViewController{
    if(self.isViewLoaded || self.reusableView){
        NSValue* v = [NSValue valueWithNonretainedObject:contentViewController];
        NSNumber* index = [self.contentViewControllerToViewIndex objectForKey:v];
        return [[self.view subviews]objectAtIndex:[index integerValue]];
    }
    return nil;
}

- (void)prepareForReuseUsingContentView:(UIView *)contentView contentViewCell:(UIView *)contentViewCell{
    [super prepareForReuseUsingContentView:contentView contentViewCell:contentViewCell];
    
    while(self.view.subviews.count < self.contentViewControllerToViewIndex.count){
        UIView* conteViewControllerView = [[UIView alloc]initWithFrame:self.view.bounds];
        conteViewControllerView.sizeToFitLayoutBoxes = NO;
        conteViewControllerView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        [self.view addSubview:conteViewControllerView];
    }
    
    //Unique instances of content view controllers
  //  CKCollectionCellContentViewController* current = [self currentContentViewController];
    NSSet* set = [NSSet setWithArray:self.contentViewControllers];
    for(CKCollectionCellContentViewController* contentViewController in set){
        UIView* contentViewControllerView = [self contentViewForContentViewController:contentViewController];
        [contentViewController prepareForReuseUsingContentView:contentViewControllerView contentViewCell:contentViewCell];
        
       // contentViewControllerView.hidden = (current != contentViewController);
    }
}

- (void)viewWillAppear:(BOOL)animated{
    BOOL willApplyStyle = (self.contentViewCell.appliedStyle == nil || [self.contentViewCell.appliedStyle isEmpty]);
    
    [super viewWillAppear:animated];
    
    if(willApplyStyle){
        for(UIView* v in self.view.subviews){
            [v setAppliedStyle:nil];
        }
    }
    
    if([self isMorphing]){
    }else{
        [[self currentContentViewController]viewWillAppear:animated];
        [self currentContentViewController].view.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[self currentContentViewController]viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if(self.transitionFromContentViewController){
        [self.transitionFromContentViewController.transition endTransition];
        [self.transitionFromContentViewController viewDidDisappear:YES];
        self.transitionFromContentViewController = nil;
    }
    
    if(self.transitionToContentViewController){
        [self.transitionToContentViewController.transition endTransition];
        self.transitionToContentViewController = nil;
    }
    
    [[self currentContentViewController]viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[self currentContentViewController]viewDidDisappear:animated];
}

@end



@interface CKCollectionCellMorphableContentViewControllerCrossFadeTransition()
@property(nonatomic,retain) NSString* imageViewIdentifier;
@end

@implementation CKCollectionCellMorphableContentViewControllerCrossFadeTransition

- (UIImage*)snapshotContentViewController:(CKCollectionCellContentViewController*)controller withFrame:(CGRect)frame{
    CGRect oldFrame = controller.view.frame;
    BOOL hidden = controller.view.hidden;
    
    controller.view.hidden = NO;
    
    controller.view.bounds = CGRectMake(0,0,frame.size.width,frame.size.height);
    [controller.view layoutSubviews];
    
    UIImage* snapshot = [controller.view snapshot];
    
    controller.view.frame = oldFrame;
    controller.view.hidden = hidden;
    
    return snapshot;
}

- (UIImageView*)imageViewForTransition{
    UIImageView* imageView = [self.view viewWithKeyPath:self.imageViewIdentifier];
    if(!imageView){
        imageView = [[UIImageView alloc]init];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleSize;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.name = self.imageViewIdentifier;
    }
    return imageView;
}

- (void)startTransition{
    [super startTransition];
   /*
    self.imageViewIdentifier = [NSString stringWithFormat:@"CKCollectionCellMorphableContentViewControllerCrossFadeTransition_%d",self.isTarget];
    
    if((self.willBeVisible) || (self.isVisible && !self.isTarget)){
        
        UIImageView* imageView = [self imageViewForTransition];
        switch(self.contentViewControllerIndex){
            case 0: { imageView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1]; break; }
            case 1: { imageView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1]; break; }
            case 2: { imageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1]; break; }
            case 3: { imageView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:1]; break; }
        }
        
        imageView.hidden = NO;
        imageView.frame = self.view.bounds;
        imageView.alpha = 1;
        imageView.image = [self snapshotContentViewController:self.contentViewController withFrame:self.frame];
        
        [self.view addSubview:imageView];
    }
    
    self.contentViewController.view.hidden = YES;
    */
}


- (void)performTransitionWithRatio:(CGFloat)ratio velocity:(CGFloat)velocity{
    [super performTransitionWithRatio:ratio velocity:velocity];
    if(!self.isPerformingTransition){
        return;
    }
    
    self.contentViewController.view.alpha = self.isTarget ? ratio : 1 - ratio;
    
   /* UIImageView* imageView = [self imageViewForTransition];
    imageView.alpha = ratio;*/
}

- (void)endTransition{
    if(!self.isPerformingTransition){
        [super endTransition];
        return;
    }
    
   /* UIImageView* imageView = [self imageViewForTransition];
    imageView.hidden = YES;*/
    
    [super endTransition];
}

@end



@implementation CKCollectionCellContentViewController(CKCollectionCellMorphableContentViewController)
@dynamic transition;
@end
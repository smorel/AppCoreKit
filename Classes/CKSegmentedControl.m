//
//  CKSegmentedControl.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-12.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKSegmentedControl.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKDebug.h"

typedef void(^CKSegmentedControlButtonBlock)();

@interface CKSegmentedControlButton()
@property(nonatomic,copy)CKSegmentedControlButtonBlock block;
@property(nonatomic,assign,readwrite)CKSegmentedControlButtonPosition position;
@property(nonatomic,assign)CKSegmentedControl* segmentedControl;
@end

@implementation CKSegmentedControlButton
@synthesize block = _block;
@synthesize position;
@synthesize segmentedControl = _segmentedControl;

- (void)postInit{
    [self addTarget:self action:@selector(execute:) forControlEvents:UIControlEventTouchUpInside];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self postInit];
    return self;
}

- (id)init{
    self = [super init];
    [self postInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self postInit];
    return self;
}

- (void)dealloc{
    [_block release];
    _block = nil;
    _segmentedControl = nil;
    [super dealloc];
}

- (void)positionMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"CKSegmentedControlButtonPosition", 
                                               CKSegmentedControlButtonPositionFirst,
                                               CKSegmentedControlButtonPositionMiddle,
                                               CKSegmentedControlButtonPositionLast,
                                               CKSegmentedControlButtonPositionAlone);
}

- (void)execute:(id)sender{
    [_segmentedControl setSelectedSegment:self];
}

@end

@interface CKSegmentedControl ()
@property(nonatomic,retain,readwrite)NSMutableArray* segments;
@end

@implementation CKSegmentedControl
@synthesize momentary,numberOfSegments,selectedSegmentIndex = _selectedSegmentIndex,segments = _segments;

- (void)dealloc
{
    [_segments release];
    _segments = nil;
    [super dealloc];
}

- (void)postInit{
    self.momentary = YES;
    _selectedSegmentIndex = -1;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self postInit];
    return self;
}

- (id)init{
    self = [super init];
    [self postInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self postInit];
    return self;
}

- (id)initWithItems:(NSArray *)items{
    self = [super init];
    for(id object in items){
        if([object isKindOfClass:[NSString class]]){
            [self insertSegmentWithTitle:object atIndex:(_segments ? [_segments count] : 0) animated:NO];
        }
        else if([object isKindOfClass:[UIImage class]]){
            [self insertSegmentWithImage:object atIndex:(_segments ? [_segments count] : 0) animated:NO];
        }
    }
    [self postInit];
    [self layoutSubviews];
    return self;
}

- (CKSegmentedControlButton*)segmentAtIndex:(NSInteger)index{
    if(_segments && index >= 0 && index < [_segments count]){
        return [_segments objectAtIndex:index];
    }
    NSAssert(NO,@"Trying to access to a non valid segment");
    return nil;
}

- (CGSize)contentOffsetForSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    return CGSizeMake(theSegment.contentEdgeInsets.left,theSegment.contentEdgeInsets.top);
}

- (void)setContentOffset:(CGSize)offset forSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    theSegment.contentEdgeInsets = UIEdgeInsetsMake(offset.height, offset.width, offset.height, offset.width);
    [theSegment sizeToFit];
    [self setNeedsLayout];
}

- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    return [theSegment imageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    [theSegment setImage:image forState:UIControlStateNormal];
    [theSegment sizeToFit];
    [self setNeedsLayout];
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    return [theSegment titleForState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    [theSegment setTitle:title forState:UIControlStateNormal];
    [theSegment sizeToFit];
    [self setNeedsLayout];
}

- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    return theSegment.enabled;
}

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    theSegment.enabled = enabled;
}

- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    return theSegment.bounds.size.width;
}

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:segment];
    CGRect bounds = theSegment.bounds;
    bounds.size.width = width;
    theSegment.bounds = bounds;
    [self setNeedsLayout];
}

- (CKSegmentedControlButton*)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated{
    return [self insertSegmentWithImage:image atIndex:segment animated:animated action:nil];
}

- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated{
    return [self insertSegmentWithTitle:title atIndex:segment animated:animated action:nil];
}

- (CKSegmentedControlButton*)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated action:(void(^)())action{
    return [self insertSegmentWithTitle:nil image:image atIndex:segment animated:animated action:action];
}

- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated action:(void(^)())action{
    return [self insertSegmentWithTitle:title image:nil atIndex:segment animated:animated action:action];
}

- (CKSegmentedControlButton*)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated target:(id)target action:(SEL)action{
    return [self insertSegmentWithTitle:nil image:image atIndex:segment animated:animated target:target action:action];
}

- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated target:(id)target action:(SEL)action{
    return [self insertSegmentWithTitle:title image:nil atIndex:segment animated:animated target:target action:action];
}

- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title image:(UIImage*)image atIndex:(NSUInteger)segment animated:(BOOL)animated target:(id)target action:(SEL)action{
    return [self insertSegmentWithTitle:title image:image atIndex:segment animated:animated action:^(){
        [target performSelector:action withObject:self];
    }];
}

- (CKSegmentedControlButton*)insertSegmentWithTitle:(NSString *)title image:(UIImage*)image atIndex:(NSUInteger)segment animated:(BOOL)animated action:(void(^)())action{
    if(_segments == nil){
        self.segments = [NSMutableArray array];
    } 
    
    CKSegmentedControlButton* theSegment = [[[CKSegmentedControlButton alloc]init]autorelease];
    [theSegment setTitle:title forState:UIControlStateNormal];
    [theSegment setImage:image forState:UIControlStateNormal];
    theSegment.segmentedControl = self;
    theSegment.block = action;
    theSegment.contentEdgeInsets = UIEdgeInsetsMake(3, 10, 3, 10);
    [theSegment sizeToFit];
    
    //Update segment positions
    if(segment == 0){
        if([_segments count] == 0){
            theSegment.position = CKSegmentedControlButtonPositionAlone;
        }
        else{
            theSegment.position = CKSegmentedControlButtonPositionFirst;
            for(int i = 1; i < [_segments count] -1 ; ++i){
                CKSegmentedControlButton* middleSegment = [self segmentAtIndex:i];
                middleSegment.position = CKSegmentedControlButtonPositionMiddle;
            }
            
            CKSegmentedControlButton* lastSegment = [self segmentAtIndex:[_segments count] - 1];
            lastSegment.position = CKSegmentedControlButtonPositionLast;
        }
    }
    else if(segment == [_segments count]){
        if([_segments count] == 0){
            theSegment.position = CKSegmentedControlButtonPositionAlone;
        }
        else{
            theSegment.position = CKSegmentedControlButtonPositionLast;
            for(int i = segment - 1; i >= 1; --i){
                CKSegmentedControlButton* middleSegment = [self segmentAtIndex:i];
                middleSegment.position = CKSegmentedControlButtonPositionMiddle;
            }
            CKSegmentedControlButton* firstSegment = [self segmentAtIndex:0];
            firstSegment.position = CKSegmentedControlButtonPositionFirst;
        }
    }
    else{
        theSegment.position = CKSegmentedControlButtonPositionMiddle;
    }
    
    [self insertSubview:theSegment atIndex:segment];
    [_segments insertObject:theSegment atIndex:segment];
    [self setNeedsLayout];
    //TODO manage animated
    
    return theSegment;
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated{
    [_segments removeObjectAtIndex:segment];
    //TODO manage animated
}

- (void)removeAllSegments{
    [_segments removeAllObjects];
    [self setNeedsLayout];
}

- (void)layoutSubviews{
    [self sizeToFit];
    CGFloat x = 0;
    for(UIButton* segment in _segments){
        CGFloat y = (self.bounds.size.height / 2.0) - (segment.bounds.size.height / 2.0);
        segment.frame = CGRectMake(x,y,segment.bounds.size.width,segment.bounds.size.height);
        x += segment.bounds.size.width;
    }
}

- (void)sizeToFit{
    CGPoint oldCenter = self.center;
    
    CGFloat width = 0;
    CGFloat height = 0;
    for(UIButton* segment in _segments){
        width += segment.bounds.size.width;
        height = MAX(height,segment.bounds.size.height);
    }
    
    self.bounds = CGRectMake(0,0,width,height);
    self.center = oldCenter;
}

- (void)setSelectedSegment:(CKSegmentedControlButton*)segment{
    if(self.momentary){
        CKSegmentedControlButton* oldSegment = _selectedSegmentIndex >= 0 ? [self segmentAtIndex:_selectedSegmentIndex] : nil;
        if(oldSegment == segment){
            return;
        }
        if(oldSegment){
            oldSegment.selected = NO;
        }
        segment.selected = YES;
    }
    
    NSInteger index = [_segments indexOfObjectIdenticalTo:segment];
    NSAssert(index != NSNotFound,@"Trying to select a segment that is not in the segmentedControl");
    _selectedSegmentIndex = index;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];

    if(segment.block){
        segment.block();
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex{
    CKSegmentedControlButton* theSegment = [self segmentAtIndex:selectedSegmentIndex];
    [self setSelectedSegment:theSegment];
}

@end

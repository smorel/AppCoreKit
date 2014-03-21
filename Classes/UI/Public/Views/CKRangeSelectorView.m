//
//  CKRangeSelectorView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-31.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKRangeSelectorView.h"
#import "UIView+Positioning.h"
#import "UIGestureRecognizer+BlockBasedInterface.h"


@interface CKRangeSelectorView()

@property(nonatomic,retain,readwrite) UIButton* startSelectorButton;
@property(nonatomic,retain,readwrite) UIButton* endSelectorButton;
@property(nonatomic,retain,readwrite) UIImageView* selectedRangeImageView;
@property(nonatomic,retain,readwrite) UIImageView* backgroundImageView;
@property(nonatomic,retain,readwrite) UILabel* startSelectorLabel;
@property(nonatomic,retain,readwrite) UILabel* endSelectorLabel;
@property(nonatomic,retain,readwrite) UILabel* joinedStartAndEndSelectorLabel;

@end

@implementation CKRangeSelectorView

- (void)dealloc{
    [_startSelectorButton release];
    [_endSelectorButton release];
    [_selectedRangeImageView release];
    [_backgroundImageView release];
    [_startSelectorLabel release];
    [_endSelectorLabel release];
    [_joinedStartAndEndSelectorLabel release];
    [_textFormat release];
    [_joinedTextFormat release];
    [_willStartEditingBlock release];
    [_didEndEditingBlock release];
    [super dealloc];
}

- (id)init{
    self = [super init];
    
    self.increment = 1;

    self.startSelectionEnabled = YES;
    self.endSelectionEnabled = YES;
    self.selectorButtonSize = CGSizeMake(-1,-1);
    
    self.textFormat = @"%f";
    self.joinedTextFormat = @"%f - %f";
    self.labelMargins = 10;
    
    self.displayType = CKRangeSelectorDisplayTypeRange;
    
    self.backgroundImageView = [[[UIImageView alloc]init]autorelease];
    self.backgroundImageView.userInteractionEnabled = NO;
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview: self.backgroundImageView];
    
    self.selectedRangeImageView = [[[UIImageView alloc]init]autorelease];
    self.selectedRangeImageView.userInteractionEnabled = NO;
    self.selectedRangeImageView.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview: self.selectedRangeImageView];
    
    self.startSelectorButton = [[[UIButton alloc]init]autorelease];
    self.startSelectorButton.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview: self.startSelectorButton];
    
    [self.startSelectorButton addGestureRecognizer:[self panGestureRecognizerForSelector:CKRangeSelectorViewSelectorLeft]];
    [self.startSelectorButton addTarget:self action:@selector(startTouched:) forControlEvents:UIControlEventTouchDown];
    [self.startSelectorButton addTarget:self action:@selector(startTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
    
    self.endSelectorButton = [[[UIButton alloc]init]autorelease];
    self.endSelectorButton.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview: self.endSelectorButton];
    
    [self.endSelectorButton addGestureRecognizer:[self panGestureRecognizerForSelector:CKRangeSelectorViewSelectorRight]];
    [self.endSelectorButton addTarget:self action:@selector(endTouched:) forControlEvents:UIControlEventTouchDown];
    [self.endSelectorButton addTarget:self action:@selector(endTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.startSelectorLabel = [[[UILabel alloc]init]autorelease];
    self.startSelectorLabel.autoresizingMask = UIViewAutoresizingNone;
    self.startSelectorLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview: self.startSelectorLabel];
    
    self.endSelectorLabel = [[[UILabel alloc]init]autorelease];
    self.endSelectorLabel.autoresizingMask = UIViewAutoresizingNone;
    self.endSelectorLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview: self.endSelectorLabel];
    
    self.joinedStartAndEndSelectorLabel = [[[UILabel alloc]init]autorelease];
    self.joinedStartAndEndSelectorLabel.autoresizingMask = UIViewAutoresizingNone;
    self.joinedStartAndEndSelectorLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview: self.joinedStartAndEndSelectorLabel];
    
    
    _minimumValue = 0;
    _maximumValue = 1;
    _startValue = 0;
    _endValue = 1;
    
    return self;
}

- (void)setDisplayType:(CKRangeSelectorDisplayType)d{
    _displayType = d;
    self.endSelectorButton.hidden = self.endSelectorLabel.hidden = (d == CKRangeSelectorDisplayTypeSingleValue);
    [self setNeedsLayout];
}

- (void)setStartValue:(CGFloat)v{
    _startValue = v;
    if(self.textFormat){
        self.startSelectorLabel.text = [NSString stringWithFormat:self.textFormat,v];
    }
    if(self.joinedTextFormat){
        self.joinedStartAndEndSelectorLabel.text = [NSString stringWithFormat:self.joinedTextFormat,_startValue,_endValue];
    }
    [self setNeedsLayout];
}


- (void)setEndValue:(CGFloat)v{
    _endValue = v;
    
    if(self.textFormat){
        self.endSelectorLabel.text = [NSString stringWithFormat:self.textFormat,v];
    }
    if(self.joinedTextFormat){
        self.joinedStartAndEndSelectorLabel.text = [NSString stringWithFormat:self.joinedTextFormat,_startValue,_endValue];
    }
    [self setNeedsLayout];
}


- (void)setMinimumValue:(CGFloat)v{
    _minimumValue = v;
    [self setNeedsLayout];
}

- (void)setMaximumValue:(CGFloat)v{
    _maximumValue = v;
    [self setNeedsLayout];
}

- (void)setStartSelectionEnabled:(BOOL)bo{
    _startSelectionEnabled = bo;
    self.startSelectorButton.hidden = !bo;
}


- (void)setEndSelectionEnabled:(BOOL)bo{
    _endSelectionEnabled = bo;
    self.endSelectorButton.hidden = !bo;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat buttonsWidth = self.startSelectorButton.width + ((self.displayType == CKRangeSelectorDisplayTypeSingleValue) ? 0 : self.endSelectorButton.width);
    CGFloat width = self.width - buttonsWidth;
    
    CGFloat fullRangeLength = self.maximumValue - self.minimumValue;
    
    CGFloat startValue = (self.startValue < self.minimumValue) ? self.minimumValue : self.startValue;
    CGFloat endValue   = (self.endValue   < startValue) ? self.maximumValue : self.endValue;
    
    CGFloat start = startValue - self.minimumValue;
    CGFloat end = start + (endValue - startValue);
    
    CGFloat startRatio = (fullRangeLength == 0) ? 0 : (start / fullRangeLength);
    CGFloat endRatio   = (fullRangeLength == 0) ? 1 : (end / fullRangeLength);
    
    CGSize buttonsSize = CGSizeMake(self.selectorButtonSize.width < 0 ? self.height : self.selectorButtonSize.width,
                                    self.selectorButtonSize.height < 0 ? self.height : self.selectorButtonSize.height);
    
    self.startSelectorButton.frame = CGRectMake((startRatio * width),(self.height - buttonsSize.height) / 2,buttonsSize.width,buttonsSize.height);
    self.endSelectorButton.frame = CGRectMake(self.selectorButtonSize.width + (endRatio * width),(self.height - buttonsSize.height) / 2,buttonsSize.width,buttonsSize.height);
    
    [self.startSelectorLabel sizeToFit];
    self.startSelectorLabel.width += 2 * self.labelMargins;
    
    if(!self.endSelectorLabel.hidden){
        [self.endSelectorLabel sizeToFit];
        self.endSelectorLabel.width += 2 * self.labelMargins;
    }
    
    //This is positioning the labels exterior to the range or inside if their is no place outside.
    if(self.startSelectorButton.x > self.startSelectorLabel.width){
        self.startSelectorLabel.frame = CGRectMake(self.startSelectorButton.x - self.startSelectorLabel.width,(self.height - self.startSelectorLabel.height) / 2,self.startSelectorLabel.width,self.startSelectorLabel.height);
        [self.startSelectorLabel setHighlighted:YES];
    }else{
        self.startSelectorLabel.frame = CGRectMake(self.startSelectorButton.x + self.startSelectorButton.width,(self.height - self.startSelectorLabel.height) / 2,self.startSelectorLabel.width,self.startSelectorLabel.height);
        [self.startSelectorLabel setHighlighted:NO];
    }
    
    if(self.displayType != CKRangeSelectorDisplayTypeSingleValue){
        if((self.width - self.endSelectorButton.x ) > (self.endSelectorLabel.width + self.endSelectorButton.width)){
            self.endSelectorLabel.frame = CGRectMake(self.endSelectorButton.x + self.endSelectorButton.width,(self.height - self.endSelectorLabel.height) / 2,self.endSelectorLabel.width,self.endSelectorLabel.height);
            [self.endSelectorLabel setHighlighted:YES];
        }else{
            self.endSelectorLabel.frame = CGRectMake(self.endSelectorButton.x - self.endSelectorLabel.width,(self.height - self.endSelectorLabel.height) / 2,self.endSelectorLabel.width,self.endSelectorLabel.height);
            [self.endSelectorLabel setHighlighted:NO];
        }
    }
    //---------------------------------------------
    
    
    
    if(self.displayType != CKRangeSelectorDisplayTypeSingleValue){
        //Adjusting the label in edge cases where the labels can overlap with each other or with start/end selectors
        if(CGRectIntersectsRect(self.startSelectorLabel.frame, self.endSelectorButton.frame)
           || CGRectIntersectsRect(self.endSelectorLabel.frame, self.startSelectorButton.frame)
           || CGRectIntersectsRect(self.endSelectorLabel.frame, self.startSelectorLabel.frame)){
            
            self.joinedStartAndEndSelectorLabel.hidden = NO;
            self.startSelectorLabel.hidden = self.endSelectorLabel.hidden = YES;
            
            //Sets the position of the joined label
            [self.joinedStartAndEndSelectorLabel sizeToFit];
            self.joinedStartAndEndSelectorLabel.width += 2 * self.labelMargins;
            
            if((self.width - self.endSelectorButton.x ) > (self.joinedStartAndEndSelectorLabel.width + self.endSelectorButton.width)){
                self.joinedStartAndEndSelectorLabel.frame = CGRectMake(self.endSelectorButton.x + self.endSelectorButton.width,(self.height - self.joinedStartAndEndSelectorLabel.height) / 2,self.joinedStartAndEndSelectorLabel.width,self.joinedStartAndEndSelectorLabel.height);
                [self.joinedStartAndEndSelectorLabel setHighlighted:YES];
            }else{
                self.joinedStartAndEndSelectorLabel.frame = CGRectMake(self.startSelectorButton.x - self.joinedStartAndEndSelectorLabel.width,(self.height - self.joinedStartAndEndSelectorLabel.height) / 2,self.joinedStartAndEndSelectorLabel.width,self.joinedStartAndEndSelectorLabel.height);
                [self.joinedStartAndEndSelectorLabel setHighlighted:YES];
            }
            
        }else{
            self.joinedStartAndEndSelectorLabel.hidden = YES;
            self.startSelectorLabel.hidden = self.endSelectorLabel.hidden = NO;
        }
        //---------------------------------------------
    }
    
    self.backgroundImageView.frame = CGRectMake(self.backgroundImageViewEdgeInsets.left,
                                                self.backgroundImageViewEdgeInsets.top,
                                                self.bounds.size.width - (self.backgroundImageViewEdgeInsets.left + self.backgroundImageViewEdgeInsets.right),
                                                self.bounds.size.height - (self.backgroundImageViewEdgeInsets.top + self.backgroundImageViewEdgeInsets.bottom));
    
    switch(self.displayType){
        case CKRangeSelectorDisplayTypeSingleValue:{
            CGFloat left = self.selectedRangeImageViewEdgeInsets.left + (self.startSelectorButton.width / 2);
            self.selectedRangeImageView.frame = CGRectMake(left,
                                                           self.selectedRangeImageViewEdgeInsets.top,
                                                           self.startSelectorButton.x+ (self.startSelectorButton.width / 2) - (left + self.selectedRangeImageViewEdgeInsets.right),
                                                           self.height - (self.selectedRangeImageViewEdgeInsets.top + self.selectedRangeImageViewEdgeInsets.bottom));
            break;
        }
        case CKRangeSelectorDisplayTypeRange:{
            self.selectedRangeImageView.frame = CGRectMake(self.selectedRangeImageViewEdgeInsets.left + self.startSelectorButton.x + (self.startSelectorButton.width / 2),
                                                           self.selectedRangeImageViewEdgeInsets.top,
                                                           self.endSelectorButton.x - self.startSelectorButton.x  - (self.selectedRangeImageViewEdgeInsets.left + self.selectedRangeImageViewEdgeInsets.right),
                                                           self.height- (self.selectedRangeImageViewEdgeInsets.top + self.selectedRangeImageViewEdgeInsets.bottom));
            break;
        }
    }
}

- (void)startTouched:(id)send{
    if(self.willStartEditingBlock){
        self.willStartEditingBlock(CKRangeSelectorViewSelectorLeft);
    }
}

- (void)endTouched:(id)send{
    if(self.willStartEditingBlock){
        self.willStartEditingBlock(CKRangeSelectorViewSelectorRight);
    }
}
- (void)startTouchEnd:(id)send{
    if(self.didEndEditingBlock){
        self.didEndEditingBlock();
    }
}

- (void)endTouchEnd:(id)send{
    if(self.didEndEditingBlock){
        self.didEndEditingBlock();
    }
}

- (UIPanGestureRecognizer*)panGestureRecognizerForSelector:(CKRangeSelectorViewSelector)selector{
    __unsafe_unretained CKRangeSelectorView* bself = self;
    
    __block CGFloat oldStartValue = 0;
    __block CGFloat oldEndValue = 0;
    UIPanGestureRecognizer* pan = [[[UIPanGestureRecognizer alloc]initWithBlock:^(UIGestureRecognizer *gestureRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
            oldStartValue = (bself.startValue < bself.minimumValue) ? bself.minimumValue : bself.startValue;
            oldEndValue = (bself.endValue   < oldStartValue) ? bself.maximumValue : bself.endValue;
        }
        else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
            UIPanGestureRecognizer* panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
            CGPoint translation = [panGesture translationInView:bself];
            
            [bself didTranslateSelector:selector offset:translation.x oldStartValue:oldStartValue oldEndValue:oldEndValue];
        }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateRecognized){
            if(bself.didEndEditingBlock){
                bself.didEndEditingBlock();
            }
        }
    }]autorelease];
    
    return pan;
}

- (void)didTranslateSelector:(CKRangeSelectorViewSelector)selector offset:(CGFloat)offset oldStartValue:(CGFloat)oldStartValue oldEndValue:(CGFloat)oldEndValue{
    CGFloat buttonsWidth = self.startSelectorButton.width + self.endSelectorButton.width;
    CGFloat width = self.width - buttonsWidth;
    
    CGFloat fullRangeLength = self.maximumValue - self.minimumValue;
    CGFloat ratio = offset / width;
    CGFloat offsetValue = ratio * fullRangeLength;
    
    CGFloat newStartValue = oldStartValue;
    CGFloat newEndValue = oldEndValue;
    
    switch(selector){
        case CKRangeSelectorViewSelectorLeft:{
            
            CGFloat newLocation = oldStartValue + offsetValue;
            if(newLocation < self.minimumValue){ newLocation = self.minimumValue; }
            if(newLocation > self.maximumValue){  newLocation = self.maximumValue; }
            
            NSInteger round = (NSInteger)(newLocation / self.increment);
            newStartValue = round * self.increment;
            newEndValue = oldEndValue;
            
            break;
        }
        case CKRangeSelectorViewSelectorRight:{
            CGFloat newEndLocation = oldEndValue + offsetValue;
            if(newEndLocation > self.maximumValue){ newEndLocation = self.maximumValue; }
            if(newEndLocation < oldStartValue){ newEndLocation = oldStartValue; }
            
            newStartValue = oldStartValue;
            
            NSInteger round = (NSInteger)(newEndLocation / self.increment);
            newEndValue = round * self.increment;
            
            break;
        }
    }
    
    if(self.startValue != newStartValue){
        self.startValue = newStartValue;
    }
    
    if(self.endValue != newEndValue){
        self.endValue = newEndValue;
    }
    
    [self setNeedsLayout];
}

@end

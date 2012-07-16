//
//  CKTextView.m
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKTextView.h"

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@interface CKTextView ()

@property (nonatomic, readwrite, retain) IBOutlet UILabel *placeholderLabel;

@end

//

@implementation CKTextView

@synthesize placeholderLabel = _placeholderLabel;
@synthesize maxStretchableHeight = _maxStretchableHeight;
@synthesize placeholderOffset = _placeholderOffset;
@synthesize frameChangeDelegate = _frameChangeDelegate;
@synthesize minHeight = _minHeight;
@synthesize numberOfExtraLines = _numberOfExtraLines;

- (void)postInit {
    self.placeholderOffset = CGPointMake(8, 8);
	self.placeholderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(_placeholderOffset.x, _placeholderOffset.y, self.bounds.size.width-(2*_placeholderOffset.x), self.font.lineHeight)] autorelease];
	self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	self.placeholderLabel.font = self.font;
	self.placeholderLabel.backgroundColor = [UIColor clearColor];
	self.placeholderLabel.textColor = [UIColor lightGrayColor];
	[self addSubview:self.placeholderLabel];

	self.maxStretchableHeight = 0;
	self.clipsToBounds = NO;
    self.scrollEnabled = NO;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueDidChange) name:UITextViewTextDidChangeNotification object:self];
	[self addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
    
    _oldFrame = self.frame;
    _frameChangeDelegate = nil;
    _minHeight = -1;
    _numberOfExtraLines = 1;
}

- (id)init {
	self = [super init];
    [self postInit];
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    [self postInit];
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
    [self postInit];
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self removeObserver:self forKeyPath:@"font"];
	self.placeholderLabel = nil;
    _frameChangeDelegate = nil;
	[super dealloc];
}

//

- (CGRect)frameForText:(NSString*)text{
    CGRect newFrame = self.frame;
    UIEdgeInsets insets = [self contentInset];
    CGFloat width = self.contentSize.width;
    
    int topMargin = 0;
    object_getInstanceVariable(self, "m_marginTop", (void **)(&topMargin));
    
    width = width - 2 * topMargin;
    NSString* str = ([self.text length] <= 0 ) ? @"a" : self.text;
    CGSize size = [str sizeWithFont:self.font 
                  constrainedToSize:CGSizeMake( width  , CGFLOAT_MAX)];
    size.height += _numberOfExtraLines * self.font.lineHeight;
    CGFloat newheight = size.height + insets.top + insets.bottom + topMargin + 5;
    newFrame.size.height = MIN(self.maxStretchableHeight, newheight);
    if(_minHeight > 0){
        newFrame.size.height = MAX(newFrame.size.height, _minHeight);
    }
    
    return newFrame;
}

- (void)updateHeightAnimated:(BOOL)animated {
	if (self.maxStretchableHeight > 0) {
        CGRect newFrame = [self frameForText:self.text];
        if(_oldFrame.size.height != newFrame.size.height){
            if(animated){
                [UIView beginAnimations:nil context:nil];
                self.frame = newFrame;
                [UIView commitAnimations];
            }
            else{
                [CATransaction begin];
                [CATransaction 
                 setValue: [NSNumber numberWithBool: YES]
                 forKey: kCATransactionDisableActions];
                self.frame = newFrame;
                [CATransaction commit];
            }
            
            if ([_frameChangeDelegate respondsToSelector:@selector(textViewFrameChanged:)]) {
                [_frameChangeDelegate textViewFrameChanged:newFrame];
            }
        }

		self.scrollEnabled = (self.contentSize.height > self.maxStretchableHeight);
        
        _oldFrame = newFrame;
	}	
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (void)setText:(NSString *)text {
	[self setText:text animated:YES];
}


- (void)setText:(NSString*)text animated:(BOOL)animated{
    [super setText:text];
    self.placeholderLabel.hidden = [self hasText];
	[self updateHeightAnimated:animated];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    self.placeholderLabel.backgroundColor = backgroundColor;
}

//

/*- (UIEdgeInsets)contentInset { return UIEdgeInsetsZero; }
-(void)setContentInset:(UIEdgeInsets)s {
	UIEdgeInsets insets = s;
	
	if(s.bottom>8) insets.bottom = 0;
	insets.top = 0;
	
	[super setContentInset:insets];
}
- (void)setContentSize:(CGSize)size {
	if (size.height == 50) {
		size.height = self.font.lineHeight + 16;
	}
	[super setContentSize:size];
}*/

- (CGPoint)contentOffset{
    return CGPointMake(0, 0);
}

- (NSString *)placeholder {
	return self.placeholderLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder {
	self.placeholderLabel.text = placeholder;
}

//

- (void)valueDidChange {
	self.placeholderLabel.hidden = [self hasText];
	
	if ([self.delegate respondsToSelector:@selector(textViewValueChanged:)]) {
		[self.delegate performSelector:@selector(textViewValueChanged:) withObject:self.text];
	}
	[self updateHeightAnimated:YES];
}



- (void)setPlaceholderOffset:(CGPoint)theplaceholderOffset{
    _placeholderOffset = theplaceholderOffset;
	self.placeholderLabel.frame = CGRectMake(_placeholderOffset.x, _placeholderOffset.y, self.bounds.size.width-(2*_placeholderOffset.x), self.font.lineHeight);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"font"]) {
		self.placeholderLabel.font = self.font;
        self.placeholderLabel.frame = CGRectMake(_placeholderOffset.x, _placeholderOffset.y, self.bounds.size.width-(2*_placeholderOffset.x), self.font.lineHeight);
	}
}

@end

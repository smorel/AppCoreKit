//
//  CKKeypadView.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKKeypadView.h"


/**
 */
@interface CKLayoutBlock : NSObject {
	NSString *_name;
	CGRect _rect;
}

@property (retain, readonly) NSString *name;
@property (assign, readonly) CGRect rect;

+ (id)blockWithSize:(CGSize)size name:(NSString *)name;

@end

//

/**
 */
typedef NS_ENUM(NSInteger, CKLayoutAlignment) {
	CKLayoutAlignmentNone = 0,
	CKLayoutAlignmentJustify
} ;


/**
 */
@interface CKKeyPadLayout : NSObject {
	// No properties.
}

+ (id)layout;
- (NSArray *)layoutBlocks:(NSArray *)blocks alignement:(CKLayoutAlignment)alignement lineWidth:(CGFloat)lineWidth lineHeight:(CGFloat)lineHeight;

@end


// See NSTextBlock
// Block padding, margin

@interface CKLayoutBlock ()

@property (retain, readwrite) NSString *name;

@end

@implementation CKLayoutBlock

@synthesize name = _name;
@synthesize rect = _rect;

- (id)initWithRect:(CGRect)rect {
	if (self = [super init]) {
		_rect = CGRectIntegral(rect);
	}
	return self;
}

- (void)dealloc {
	[_name release];
	[super dealloc];
}

+ (id)blockWithRect:(CGRect)rect {
	return [[[CKLayoutBlock alloc] initWithRect:rect] autorelease];
}

+ (id)blockWithSize:(CGSize)size name:(NSString *)name {
	CKLayoutBlock *block = [CKLayoutBlock blockWithRect:CGRectMake(0, 0, size.width, size.height)];
	block.name = name;
	return block;
}

//

- (NSString *)description {
	return [NSString stringWithFormat:@"<CKLayoutBlock [%@]%@>", NSStringFromCGRect(_rect), 
			self.name ? [NSString stringWithFormat:@" %@", self.name] : @""];
}

@end

//

@implementation CKKeyPadLayout

+ (id)layout {
	return [[[CKKeyPadLayout alloc] init] autorelease];
}

//

- (NSArray *)layoutLineOfBlocks:(NSArray *)blocks 
					  lineIndex:(NSUInteger)lineIndex 
					  lineWidth:(CGFloat)lineWidth 
					 lineHeight:(CGFloat)lineHeight 
					  justified:(BOOL)justified {
    
	// Compute the total length of the current blocks in order to calculate
	// the length ratio.
	
	CGFloat length = 0;
	for (CKLayoutBlock *block in blocks) { 
		length += block.rect.size.width; 
	}
	
	// Create new aligned blocks; expanding width so that they will fit the
	// line (the width of each block respect the aspect ratio from their
	// original size).
	
	NSMutableArray *theBlocks = [NSMutableArray array];
	
	CGFloat offset = 0;
	for (CKLayoutBlock *block in blocks) {
		CGFloat theWidth = justified ? ((block.rect.size.width / length) * lineWidth) : block.rect.size.width;
		CKLayoutBlock *theBlock = [CKLayoutBlock blockWithRect:CGRectMake(offset, lineIndex * lineHeight, theWidth, lineHeight)];
		theBlock.name = block.name;
		[theBlocks addObject:theBlock];
		offset += theBlock.rect.size.width;
	}
	
	return theBlocks;
}

- (NSArray *)layoutBlocks:(NSArray *)blocks alignement:(CKLayoutAlignment)alignement lineWidth:(CGFloat)lineWidth lineHeight:(CGFloat)lineHeight {
	
	// #1 break blocks in lines
	
	NSEnumerator *e = [blocks objectEnumerator];
	NSMutableArray *linesOfBlocks = [NSMutableArray array];
	NSMutableArray *currentLineOfBlocks = [NSMutableArray array];
	CGFloat lineWidthLeft = lineWidth;
	
	for (CKLayoutBlock *block = [e nextObject]; block; ) {
		if (block.rect.size.width <= lineWidthLeft) {
			[currentLineOfBlocks addObject:block];
			lineWidthLeft -= block.rect.size.width;
			block = [e nextObject];
			continue;
		}
		
		[linesOfBlocks addObject:currentLineOfBlocks];		
		currentLineOfBlocks = [NSMutableArray array];
		lineWidthLeft = lineWidth;
        
		// Handle the case of a block.width > line-width, insert it in as 
		// a block on a single line.
		
		if (block.rect.size.width > lineWidth) {
			[linesOfBlocks addObject:[NSArray arrayWithObject:block]];
			block = [e nextObject];
		}		
	}
	
	if (currentLineOfBlocks.count != 0) {
		[linesOfBlocks addObject:currentLineOfBlocks];	
	}
	
	// #2 justify blocks for each line; aggregate the results in a new array
	// of blocks
	
	NSMutableArray *theBlocks = [NSMutableArray array];
	
	for (NSUInteger i = 0; i < linesOfBlocks.count; i++) {
		[theBlocks addObjectsFromArray:[self layoutLineOfBlocks:[linesOfBlocks objectAtIndex:i] 
													  lineIndex:i 
													  lineWidth:lineWidth 
													 lineHeight:lineHeight
													  justified:(alignement == CKLayoutAlignmentJustify)]];
	}
	
	return theBlocks;
}

@end





@interface UIView (CKUIViewLayoutAdditions)
- (void)layoutSubviewsWithColumns:(NSUInteger)nbColumns lines:(NSUInteger)nbLines;
@end

@implementation UIView (CKUIViewLayoutAdditions)


- (void)layoutSubviewsWithColumns:(NSUInteger)nbColumns lines:(NSUInteger)nbLines {
	CGSize blockSize = CGSizeMake(self.bounds.size.width / nbColumns, self.bounds.size.height / nbLines);
	
	// Generate the blocks
	NSMutableArray *blocks = [NSMutableArray array];
	NSInteger count;
	for (count=0 ; count<nbColumns*nbLines ; count++) {
		[blocks addObject:[CKLayoutBlock blockWithSize:blockSize name:@"GridBlock"]];
	}
	NSArray *layoutBlocks = [[CKKeyPadLayout layout] layoutBlocks:blocks alignement:CKLayoutAlignmentJustify lineWidth:self.bounds.size.width lineHeight:blockSize.height];
	
	count = 0;
	for (UIView *view in self.subviews) {
		if (count <= layoutBlocks.count) {
			CKLayoutBlock *block = [layoutBlocks objectAtIndex:count++];
			view.frame = block.rect;
		}
		else {
			view.hidden = YES;		// Hide the view if there are more views than blocks
		}
        
	}
}

@end


@interface CKKeypadView ()
- (void)constructView;
@end


@implementation CKKeypadView

@synthesize value = _value;
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.value = @"";
		[self constructView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.value = @"";
		[self constructView];
	}
	return self;
}

- (void)dealloc {
	self.value = nil;
    [super dealloc];
}


- (void)addButtonForKey:(CKKeypadViewKey)key {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 10, 10);
	button.tag = key;
	if (key < 1000) [button setTitle:[NSString stringWithFormat:@"%ld",(long)key] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchUpInside];

	// Theming
	[button setBackgroundImage:[UIImage imageNamed:@"CKKeypadViewButtonBackground.png"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"CKKeypadViewButtonBackground.png"] forState:UIControlStateDisabled];
	[button setBackgroundImage:[UIImage imageNamed:@"CKKeypadViewButtonBackground-Highlighted.png"] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[UIImage imageNamed:@"CKKeypadViewButtonBackground-Selected.png"] forState:UIControlStateSelected];
	[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
	[button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateSelected];
	button.titleLabel.shadowOffset = CGSizeMake(0, 1);
	button.titleLabel.font = [UIFont boldSystemFontOfSize:40];
	
	if (key == CKKeypadViewKeyBackspace) {
		[button setImage:[UIImage imageNamed:@"CKKeypadViewBackspaceButton.png"] forState:UIControlStateNormal];
		[button setImage:[UIImage imageNamed:@"CKKeypadViewBackspaceButton-Highlighted.png"] forState:UIControlStateHighlighted];
		[button setImage:[UIImage imageNamed:@"CKKeypadViewBackspaceButton-Selected.png"] forState:UIControlStateSelected];
	}
	if (key == CKKeypadViewKeyNone) button.enabled = NO;

	[self addSubview:button];
}

- (void)constructView {
	// 1 - 9
	for (int i=1 ; i<10 ; i++) {
		[self addButtonForKey:i];
	}

	// Empty
	[self addButtonForKey:CKKeypadViewKeyNone];

	// 0
	[self addButtonForKey:CKKeypadViewKeyZero];

	// Backspace
	[self addButtonForKey:CKKeypadViewKeyBackspace];
}


- (void)layoutSubviews {
	[super layoutSubviews];
	[self layoutSubviewsWithColumns:3 lines:4];	
}

- (void)keyPressed:(id)sender {
	UIButton *button = (UIButton *)sender;

	switch (button.tag) {
		case CKKeypadViewKeyBackspace:
			if (self.value.length > 0) self.value = [self.value substringToIndex:self.value.length-1];
			break;
		default:
			if ([(NSObject *)self.delegate respondsToSelector:@selector(keypadView:shouldSelectKey:)] &&
				[self.delegate keypadView:self shouldSelectKey:button.tag] == NO)
				return;
			self.value = [NSString stringWithFormat:@"%@%ld", self.value, (long)button.tag];
			break;
	}

	if ([(NSObject *)self.delegate respondsToSelector:@selector(keypadView:didSelectKey:)])
		[self.delegate keypadView:self didSelectKey:button.tag];
}


@end

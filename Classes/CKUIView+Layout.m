//
//  CKUIView+Layout.m
//  YellowPages
//
//  Created by Olivier Collet on 10-05-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Layout.h"
#import "CKLayout.h"


@implementation UIView (CKUIViewLayoutAdditions)


- (void)layoutSubviewsWithColumns:(NSUInteger)nbColumns lines:(NSUInteger)nbLines {
	CGSize blockSize = CGSizeMake(self.bounds.size.width / nbColumns, self.bounds.size.height / nbLines);
	
	// Generate the blocks
	NSMutableArray *blocks = [NSMutableArray array];
	NSInteger count;
	for (count=0 ; count<nbColumns*nbLines ; count++) {
		[blocks addObject:[CKLayoutBlock blockWithSize:blockSize name:@"GridBlock"]];
	}
	NSArray *layoutBlocks = [[CKLayout layout] layoutBlocks:blocks alignement:CKLayoutAlignmentJustify lineWidth:self.bounds.size.width lineHeight:blockSize.height];
	
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

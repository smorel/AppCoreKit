//
//  CKLayout.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-22.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKLayoutBlock : NSObject {
	NSString *_name;
	CGRect _rect;
}

@property (retain, readonly) NSString *name;
@property (assign, readonly) CGRect rect;

+ (id)blockWithSize:(CGSize)size name:(NSString *)name;

@end

//

typedef enum {
	CKLayoutAlignmentJustify = 0
} CKLayoutAlignment;

@interface CKLayout : NSObject {
	// No properties.
}

+ (id)layout;
- (NSArray *)layoutBlocks:(NSArray *)blocks alignement:(CKLayoutAlignment)alignement lineWidth:(CGFloat)lineWidth lineHeight:(CGFloat)lineHeight;
	
@end
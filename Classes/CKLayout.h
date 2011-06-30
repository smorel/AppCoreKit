//
//  CKLayout.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-22.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
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

/** TODO
 */
typedef enum {
	CKLayoutAlignmentNone = 0,
	CKLayoutAlignmentJustify
} CKLayoutAlignment;


/** TODO
 */
@interface CKLayout : NSObject {
	// No properties.
}

+ (id)layout;
- (NSArray *)layoutBlocks:(NSArray *)blocks alignement:(CKLayoutAlignment)alignement lineWidth:(CGFloat)lineWidth lineHeight:(CGFloat)lineHeight;
	
@end
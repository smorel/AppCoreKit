//
//  CKTextView.h
//  CloudKit
//
//  Created by Olivier Collet on 10-11-24.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
@interface CKTextView : UITextView {
	UILabel *_placeholderLabel;
	CGFloat _maxStretchableHeight;
	CGFloat _minHeight;
    CGPoint _placeholderOffset;
    CGRect _oldFrame;
    NSInteger _numberOfExtraLines;
    id _frameChangeDelegate;
}

@property (nonatomic, readonly, retain) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, assign) NSString *placeholder;
@property (nonatomic, assign) CGFloat maxStretchableHeight;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGPoint placeholderOffset;
@property (nonatomic, assign) NSInteger numberOfExtraLines;
@property (nonatomic, assign) id frameChangeDelegate;

- (void)updateHeightAnimated:(BOOL)animated;
- (CGRect)frameForText:(NSString*)text;
- (void)setText:(NSString*)text animated:(BOOL)animated;

@end

//


/** TODO
 */
@protocol CKTextViewDelegate

-(void)textViewValueChanged:(NSString*)text;
-(void)textViewFrameChanged:(CGRect)frame;

@end
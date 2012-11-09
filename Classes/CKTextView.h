//
//  CKTextView.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** 
 */
@interface CKTextView : UITextView 

///-----------------------------------
/// @name Managing the delegate
///-----------------------------------

/**
 */
@property (nonatomic, assign) id frameChangeDelegate;

///-----------------------------------
/// @name Getting the placeholder label
///-----------------------------------

/**
 */
@property (nonatomic, readonly, retain) IBOutlet UILabel *placeholderLabel;

///-----------------------------------
/// @name Customizing the placeholder
///-----------------------------------

/**
 */
@property (nonatomic, assign) NSString *placeholder;
@property (nonatomic, assign) CGPoint placeholderOffset;

///-----------------------------------
/// @name Managing the text
///-----------------------------------

/**
 */
- (void)setText:(NSString*)text animated:(BOOL)animated;

///-----------------------------------
/// @name Managing the text view frame
///-----------------------------------

/**
 */
@property (nonatomic, assign) NSInteger numberOfExtraLines;

/**
 */
@property (nonatomic, assign) CGFloat maxStretchableHeight;
/**
 */
@property (nonatomic, assign) CGFloat minHeight;

/**
 */
- (CGRect)frameForText:(NSString*)text;

/**
 */
- (void)updateHeightAnimated:(BOOL)animated;

@end

//


/** 
 */
@protocol CKTextViewDelegate

///-----------------------------------
/// @name Reacting to text view events
///-----------------------------------

/** 
 */
-(void)textViewValueChanged:(NSString*)text;

/** 
 */
-(void)textViewFrameChanged:(CGRect)frame;

@end
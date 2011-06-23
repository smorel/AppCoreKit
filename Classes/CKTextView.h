//
//  CKTextView.h
//  CloudKit
//
//  Created by Olivier Collet on 10-11-24.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CKTextView : UITextView {
	UILabel *_placeholderLabel;
	CGFloat _maxStretchableHeight;
}

@property (nonatomic, readonly, retain) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, assign) NSString *placeholder;
@property (nonatomic, assign) CGFloat maxStretchableHeight;

- (void)updateHeight;

@end

//

@protocol CKTextViewDelegate

-(void)textViewValueChanged:(NSString*)text;

@end
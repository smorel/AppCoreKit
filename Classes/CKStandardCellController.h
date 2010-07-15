//
//  CKStandardCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-06-10.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"
#import "CKWebRequest.h"


@interface CKStandardCellController : CKTableViewCellController <CKWebRequestDelegate> {
	UITableViewCellStyle _style;
	NSString *_text;
	NSString *_detailedText;

	NSString *_imageURL;
	UIImage *_fetchedImage;
	UIImage *_image;
	CKWebRequest *_request;

	UIColor *_backgroundColor;
	UIColor *_textColor;
	UIColor *_detailedTextColor;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *detailedText;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *detailedTextColor;

- (id)initWithStyle:(UITableViewCellStyle)style;
- (id)initWithText:(NSString *)text;
- (id)initWithStyle:(UITableViewCellStyle)style imageURL:(NSString *)imageURL text:(NSString *)text;

@end

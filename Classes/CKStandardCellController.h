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
#import "CKModelObject.h"

@interface CKStandardCellControllerStyle : CKModelObject{}
@property (nonatomic,assign) UITableViewCellStyle cellStyle;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *detailedTextColor;
@property (nonatomic, assign) BOOL isTextMultiline;
@property (nonatomic, assign) BOOL isDetailTextMultiline;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;

+ (CKStandardCellControllerStyle*)defaultStyle;
+ (CKStandardCellControllerStyle*)value1Style;
+ (CKStandardCellControllerStyle*)value2Style;
+ (CKStandardCellControllerStyle*)subtitleStyle;

@end

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

	BOOL _multilineText;
	BOOL _multilineDetailText;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *detailedText;
@property (nonatomic, retain) UIImage *image                     DEPRECATED_ATTRIBUTE;//use CKStandardCellControllerStyle instead 
@property (nonatomic, retain) UIColor *backgroundColor           DEPRECATED_ATTRIBUTE;//use CKStandardCellControllerStyle instead 
@property (nonatomic, retain) UIColor *textColor                 DEPRECATED_ATTRIBUTE;//use CKStandardCellControllerStyle instead 
@property (nonatomic, retain) UIColor *detailedTextColor         DEPRECATED_ATTRIBUTE;//use CKStandardCellControllerStyle instead 

@property (nonatomic, assign, getter=isTextMultiline) BOOL multilineText;
@property (nonatomic, assign, getter=isDetailTextMultiline) BOOL multilineDetailText;

- (id)initWithStyle:(UITableViewCellStyle)style DEPRECATED_ATTRIBUTE;
- (id)initWithText:(NSString *)text;
- (id)initWithStyle:(UITableViewCellStyle)style imageURL:(NSString *)imageURL text:(NSString *)text DEPRECATED_ATTRIBUTE;

- (id)initWithStandardStyle:(CKStandardCellControllerStyle*)style;
- (id)initWithStandardStyle:(CKStandardCellControllerStyle*)style imageURL:(NSString *)imageURL text:(NSString *)text;
@end

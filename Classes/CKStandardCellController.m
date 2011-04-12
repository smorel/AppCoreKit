//
//  CKStandardCellController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-10.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKStandardCellController.h"
#import "CKUIImage+Transformations.h"
#import "CKCache.h"
#import "CKDebug.h"

static CKStandardCellControllerStyle* CKStandardCellControllerDefaultStyle = nil;
static CKStandardCellControllerStyle* CKStandardCellControllerValue1Style = nil;
static CKStandardCellControllerStyle* CKStandardCellControllerValue2Style = nil;
static CKStandardCellControllerStyle* CKStandardCellControllerSubtitleStyle = nil;

@implementation CKStandardCellControllerStyle
@synthesize cellStyle,image,backgroundColor,textColor,detailedTextColor,isTextMultiline,isDetailTextMultiline,accessoryType;

+ (CKStandardCellControllerStyle*)defaultStyle{
	if(CKStandardCellControllerDefaultStyle == nil){
		CKStandardCellControllerDefaultStyle = [[CKStandardCellControllerStyle alloc]init];
		CKStandardCellControllerDefaultStyle.cellStyle = UITableViewCellStyleDefault;
		CKStandardCellControllerDefaultStyle.textColor = [UIColor blackColor];
		CKStandardCellControllerDefaultStyle.detailedTextColor = [UIColor blackColor];
		CKStandardCellControllerDefaultStyle.isTextMultiline = NO;
		CKStandardCellControllerDefaultStyle.isDetailTextMultiline = NO;
		//define other default properties
	}
	return CKStandardCellControllerDefaultStyle;
}

+ (CKStandardCellControllerStyle*)value1Style{
	if(CKStandardCellControllerValue1Style == nil){
		CKStandardCellControllerValue1Style = [[CKStandardCellControllerStyle defaultStyle] copy];
		CKStandardCellControllerValue1Style.cellStyle = UITableViewCellStyleValue1;
	}
	return CKStandardCellControllerValue1Style;
}

+ (CKStandardCellControllerStyle*)value2Style{
	if(CKStandardCellControllerValue2Style == nil){
		CKStandardCellControllerValue2Style = [[CKStandardCellControllerStyle defaultStyle] copy];
		CKStandardCellControllerValue2Style.cellStyle = UITableViewCellStyleValue2;
	}
	return CKStandardCellControllerValue1Style;
}

+ (CKStandardCellControllerStyle*)subtitleStyle{
	if(CKStandardCellControllerSubtitleStyle == nil){
		CKStandardCellControllerSubtitleStyle = [[CKStandardCellControllerStyle defaultStyle] copy];
		CKStandardCellControllerSubtitleStyle.cellStyle = UITableViewCellStyleSubtitle;
	}
	return CKStandardCellControllerSubtitleStyle;
}

@end



@interface CKStandardCellController ()

@property (nonatomic, assign) UITableViewCellStyle style;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) UIImage *fetchedImage;
@property (nonatomic, retain) CKWebRequest *request;

- (NSString *)cacheKeyForImage;

@end

//

@implementation CKStandardCellController

@synthesize style = _style;
@synthesize text = _text;
@synthesize detailedText = _detailedText;
@synthesize imageURL = _imageURL;
@synthesize fetchedImage = _fetchedImage;
@synthesize image = _image;
@synthesize request = _request;
@synthesize backgroundColor = _backgroundColor;
@synthesize textColor = _textColor;
@synthesize detailedTextColor = _detailedTextColor;
@synthesize multilineText = _multilineText;
@synthesize multilineDetailText = _multilineDetailText;


- (id)initWithStandardStyle:(CKStandardCellControllerStyle*)style{
	if (self = [super init]) {
		self.controllerStyle = style;
	}
	return self;
}

- (id)initWithStandardStyle:(CKStandardCellControllerStyle*)style imageURL:(NSString *)imageURL text:(NSString *)text{
	if ([self initWithStandardStyle:style]) {
		self.imageURL = imageURL;
		self.fetchedImage = [[CKCache sharedCache] imageForKey:[self cacheKeyForImage]];
		self.text = text;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style {
	if (self = [super init]) {
		self.style = style;
	}
	return self;
}

- (id)initWithText:(NSString *)text {
	if ([self initWithStandardStyle:[CKStandardCellControllerStyle defaultStyle]]) {
		self.text = text;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style imageURL:(NSString *)imageURL text:(NSString *)text {
	if ([self initWithStyle:style]) {
		self.imageURL = imageURL;
		self.fetchedImage = [[CKCache sharedCache] imageForKey:[self cacheKeyForImage]];
		self.text = text;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return self;
}

- (void)dealloc {
	//DEPRECATED ATTRIBUTES
	self.image = nil;
	self.backgroundColor = nil;
	self.textColor = nil;
	self.detailedTextColor = nil;
	
	self.text = nil;
	self.detailedText = nil;
	self.imageURL = nil;
	self.fetchedImage = nil;
	[self.request cancel];
	self.request = nil;
	[super dealloc];
}

- (NSString *)identifier {
	if(self.controllerStyle){
		return [NSString stringWithFormat:@"%@-<%p>", [super identifier], self.controllerStyle];
	}
	//FIXME DEPRECATED
	return [NSString stringWithFormat:@"%@-%d", [super identifier], self.style];
}

- (NSString *)cacheKeyForImage {
	return [NSString stringWithFormat:@"cell-%@", self.imageURL];
}

//

- (void)cellDidAppear:(UITableViewCell *)cell {
	if (self.imageURL && [self.imageURL length] > 0 && (self.fetchedImage == nil) && (self.request == nil)) {
		self.request = [CKWebRequest requestWithURLString:self.imageURL params:nil delegate:self];
		[self.request start];
	}
}

- (void)cellDidDisappear {
	[self.request cancel];
}

- (UITableViewCell *)loadCell {
	CKStandardCellControllerStyle* theStyle = (CKStandardCellControllerStyle*)self.controllerStyle;
	//FIXME When no support for DEPRECATED :
	//CKStandardCellControllerStyle* theStyle = (self.controllerStyle == nil) ?  [CKStandardCellControllerStyle defaultStyle] : (CKStandardCellControllerStyle*)self.controllerStyle;
	
	UITableViewCell *cell = (theStyle != nil) ? [self cellWithStyle:theStyle.cellStyle] : [self cellWithStyle:self.style];
	cell.accessoryType = (theStyle != nil) ? theStyle.accessoryType : self.accessoryType;
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	[self.request cancel];
	
	CKStandardCellControllerStyle* theStyle = (CKStandardCellControllerStyle*)self.controllerStyle;
	//FIXME When no support for DEPRECATED :
	//CKStandardCellControllerStyle* theStyle = (self.controllerStyle == nil) ?  [CKStandardCellControllerStyle defaultStyle] : (CKStandardCellControllerStyle*)self.controllerStyle;
	
	if (self.backgroundColor) cell.backgroundColor             = (theStyle != nil) ? theStyle.backgroundColor : self.backgroundColor;
	if (self.textColor) cell.textLabel.textColor               = (theStyle != nil) ? theStyle.textColor : self.textColor;
	if (self.detailedTextColor) cell.detailTextLabel.textColor = (theStyle != nil) ? theStyle.detailedTextColor : self.detailedTextColor;
	if ((theStyle != nil) ? theStyle.isTextMultiline : self.isTextMultiline) cell.textLabel.numberOfLines = 0;
	if ((theStyle != nil) ? theStyle.isDetailTextMultiline : self.isDetailTextMultiline) cell.detailTextLabel.numberOfLines = 0;

	cell.imageView.image = self.fetchedImage ? self.fetchedImage : ((theStyle != nil) ? theStyle.image : self.image);
	cell.textLabel.text = self.text;
	cell.detailTextLabel.text = self.detailedText;
}

#pragma mark CKWebRequestDelegate Protocol

- (void)request:(id)request didReceiveValue:(id)value {
	self.request = nil;
	
	CKStandardCellControllerStyle* theStyle = (CKStandardCellControllerStyle*)self.controllerStyle;
	//FIXME When no support for DEPRECATED :
	//CKStandardCellControllerStyle* theStyle = (self.controllerStyle == nil) ?  [CKStandardCellControllerStyle defaultStyle] : (CKStandardCellControllerStyle*)self.controllerStyle;
	UIImage* defaultImage = (theStyle != nil) ? theStyle.image : self.image;
	UIImage *image = defaultImage ? [value imageThatFits:defaultImage.size crop:YES] : value;
	[[CKCache sharedCache] setImage:image forKey:[self cacheKeyForImage]];
	self.fetchedImage = image;
	[self setNeedsSetup];
}

- (void)request:(id)request didFailWithError:(NSError *)error {
	self.request = nil;
	CKDebugLog(@"%@", error);
}

@end

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
#import "CKStyleManager.h"

@interface CKStandardCellController ()

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


- (id)initWithStyle:(UITableViewCellStyle)style {
	if (self = [super init]) {
		self.style = style;
	}
	return self;
}

- (id)initWithText:(NSString *)text {
	if ([self initWithStyle:UITableViewCellStyleDefault]) {
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
	NSDictionary* controllerStyle = [self controllerStyle];
	if(controllerStyle){
		return [NSString stringWithFormat:@"%@-<%p>", [super identifier], controllerStyle];
	}
	//FIXME DEPRECATED
	return [NSString stringWithFormat:@"%@-%d", [super identifier], self.style];
}

- (NSString *)cacheKeyForImage {
	return [NSString stringWithFormat:@"cell-%@", self.imageURL];
}

//

- (void)cellDidAppear:(UITableViewCell *)cell {
	[super cellDidAppear:cell];
	if (self.imageURL && [self.imageURL length] > 0 && (self.fetchedImage == nil) && (self.request == nil)) {
		self.request = [CKWebRequest requestWithURLString:self.imageURL params:nil delegate:self];
		[self.request start];
	}
}

- (void)cellDidDisappear {
	[self.request cancel];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	[self.request cancel];
	
	if(self.fetchedImage != nil || self.image != nil){
		cell.imageView.image = self.fetchedImage ? self.fetchedImage : self.image;
	}
	if(self.text){
		cell.textLabel.text = self.text;
	}
	if(self.detailedText){
		cell.detailTextLabel.text = self.detailedText;
	}
}

#pragma mark CKWebRequestDelegate Protocol

- (void)request:(id)request didReceiveValue:(id)value {
	self.request = nil;
	
	UIImage* defaultImage = self.tableViewCell.imageView.image;
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

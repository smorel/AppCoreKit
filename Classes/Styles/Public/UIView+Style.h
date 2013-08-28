//
//  UIView+Style.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStyleView.h"
#import "NSObject+Runtime.h"

/**
 */
typedef enum{
	CKViewCornerStyleTableViewCell,//in this case, we set the corner style of the parent controller (table plain or grouped)
	//in the following case, we force the corner style of the cell and bypass the parent controller style
	CKViewCornerStyleRounded,
	CKViewCornerStyleRoundedTop,
	CKViewCornerStyleRoundedBottom,
	CKViewCornerStylePlain
}CKViewCornerStyle;


/**
 */
typedef enum{
	CKViewBorderStyleNone          = 0,
	CKViewBorderStyleTableViewCell = 1 << 1,
	CKViewBorderStyleLeft          = 1 << 2,
	CKViewBorderStyleRight         = 1 << 3,
	CKViewBorderStyleTop           = 1 << 4,
	CKViewBorderStyleBottom        = 1 << 5,
	CKViewBorderStyleAll = CKViewBorderStyleLeft | CKViewBorderStyleRight | CKViewBorderStyleTop | CKViewBorderStyleBottom
}CKViewBorderStyle;

typedef enum{
	CKViewSeparatorStyleTableViewCell,
	CKViewSeparatorStyleTop,
	CKViewSeparatorStyleBottom,
	CKViewSeparatorStyleLeft,
	CKViewSeparatorStyleRight
}CKViewSeparatorStyle;


/**
 */
extern NSString* CKStyleBackgroundColor;

/**
 */
extern NSString* CKStyleBackgroundGradientColors;

/**
 */
extern NSString* CKStyleBackgroundGradientLocations;

/**
 */
extern NSString* CKStyleBackgroundImage;

/**
 */
extern NSString* CKStyleBackgroundImageContentMode;

/**
 */
extern NSString* CKStyleCornerStyle;

/**
 */
extern NSString* CKStyleCornerSize;

/**
 */
extern NSString* CKStyleAlpha;

/**
 */
extern NSString* CKStyleBorderColor;

/**
 */
extern NSString* CKStyleBorderWidth;

/**
 */
extern NSString* CKStyleBorderStyle;

/**
 */
extern NSString* CKStyleSeparatorColor;

/**
 */
extern NSString* CKStyleSeparatorWidth;

/**
 */
extern NSString* CKStyleSeparatorStyle;

/**
 */
extern NSString* CKStyleBorderShadowColor;

extern NSString* CKStyleViewDescription;
extern NSString* CKStyleAutoLayoutConstraints;
extern NSString* CKStyleAutoLayoutFormatOption;
extern NSString* CKStyleAutoLayoutFormat;
extern NSString* CKStyleAutoLayoutHugging;
extern NSString* CKStyleAutoLayoutCompression;


/**
 */
@interface NSMutableDictionary (CKViewStyle)

- (UIColor*)backgroundColor;
- (NSArray*)backgroundGradientColors;
- (NSArray*)backgroundGradientLocations;
- (UIViewContentMode)backgroundImageContentMode;
- (UIImage*)backgroundImage;
- (CKViewCornerStyle)cornerStyle;
- (CGFloat)cornerSize;
- (CGFloat)alpha;
- (UIColor*)borderColor;
- (CGFloat)borderWidth;
- (CKViewBorderStyle)borderStyle;
- (UIColor*)separatorColor;
- (CGFloat)separatorWidth;
- (CKViewSeparatorStyle)separatorStyle;
- (UIViewContentMode)contentMode;
- (BOOL)clipsToBounds;

- (NSArray*)instanceOfViews;

/*
#ifdef __IPHONE_6_0
- (NSArray*)autoLayoutConstraintsUsingViews:(NSDictionary*)views;
#endif
 */

@end


//TODO : rename style by parentStyle in some APIs

/**
 */
@interface UIView (CKStyle)
- (NSMutableDictionary*)applyStyle:(NSMutableDictionary*)style;
- (NSMutableDictionary*)applyStyle:(NSMutableDictionary*)style propertyName:(NSString*)propertyName;

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate;

//private
+ (BOOL)needSubView:(NSMutableDictionary*)style forView:(UIView*)view;

- (void)populateViewDictionaryForVisualFormat:(NSMutableDictionary*)dico;

/*
#ifdef __IPHONE_6_0
- (void)setTranslatesAutoresizingMaskIntoConstraints:(BOOL)flag recursive:(BOOL)recursive;
#endif
 */

@end


/**
 */
@interface NSObject (CKStyle)
@property(nonatomic,retain)NSMutableDictionary* appliedStyle;
@property(nonatomic,retain)NSMutableDictionary* debugAppliedStyle;

- (NSString*)appliedStylePath;
- (NSString*)appliedStyleDescription;

+ (void)updateReservedKeyWords:(NSMutableSet*)keyWords;
- (NSMutableDictionary*)applyStyle:(NSMutableDictionary*)style;
+ (BOOL)applyStyle:(NSMutableDictionary*)style toObject:(id)object appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate;

- (void)applySubViewsStyle:(NSMutableDictionary*)style appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate;
+ (void)applyStyleByIntrospection:(NSMutableDictionary*)style toObject:(id)object appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate;

@end


/**
 */
@protocol CKStyleDelegate
@optional

- (CKStyleViewCornerType)view:(UIView*)view cornerStyleWithStyle:(NSMutableDictionary*)style;
- (CKStyleViewBorderLocation)view:(UIView*)view borderStyleWithStyle:(NSMutableDictionary*)style;
- (CKStyleViewSeparatorLocation)view:(UIView*)view separatorStyleWithStyle:(NSMutableDictionary*)style;
- (UIColor*)separatorColorForView:(UIView*)view withStyle:(NSMutableDictionary*)style;
- (BOOL)object:(id)object shouldReplaceViewWithDescriptor:(CKClassPropertyDescriptor*)descriptor withStyle:(NSMutableDictionary*)style;

@end
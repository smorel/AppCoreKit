//
//  CKUIView+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStyleView.h"
#import "CKNSObject+CKRuntime.h"

/** TODO
 */
typedef enum{
	CKViewCornerStyleTableViewCell,//in this case, we set the corner style of the parent controller (table plain or grouped)
	//in the following case, we force the corner style of the cell and bypass the parent controller style
	CKViewCornerStyleRounded,
	CKViewCornerStyleRoundedTop,
	CKViewCornerStyleRoundedBottom,
	CKViewCornerStylePlain
}CKViewCornerStyle;


/** TODO
 */
typedef enum{
	CKViewBorderStyleTableViewCell,
	CKViewBorderStyleAll,
	CKViewBorderStyleNone
}CKViewBorderStyle;

typedef enum{
	CKViewSeparatorStyleTableViewCell,
	CKViewSeparatorStyleTop,
	CKViewSeparatorStyleBottom,
	CKViewSeparatorStyleLeft,
	CKViewSeparatorStyleRight
}CKViewSeparatorStyle;


/** TODO
 */
extern NSString* CKStyleBackgroundColor;

/** TODO
 */
extern NSString* CKStyleBackgroundGradientColors;

/** TODO
 */
extern NSString* CKStyleBackgroundGradientLocations;

/** TODO
 */
extern NSString* CKStyleBackgroundImage;

/** TODO
 */
extern NSString* CKStyleBackgroundImageContentMode;

/** TODO
 */
extern NSString* CKStyleCornerStyle;

/** TODO
 */
extern NSString* CKStyleCornerSize;

/** TODO
 */
extern NSString* CKStyleAlpha;

/** TODO
 */
extern NSString* CKStyleBorderColor;

/** TODO
 */
extern NSString* CKStyleBorderWidth;

/** TODO
 */
extern NSString* CKStyleBorderStyle;

/** TODO
 */
extern NSString* CKStyleSeparatorColor;

/** TODO
 */
extern NSString* CKStyleSeparatorWidth;

/** TODO
 */
extern NSString* CKStyleSeparatorStyle;


extern NSString* CKStyleViewDescription;
extern NSString* CKStyleAutoLayoutConstraints;
extern NSString* CKStyleAutoLayoutFormatOption;
extern NSString* CKStyleAutoLayoutFormat;
extern NSString* CKStyleAutoLayoutHugging;
extern NSString* CKStyleAutoLayoutCompression;


/** TODO
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


- (NSArray*)instanceOfViews;

#ifdef __IPHONE_6_0
- (NSArray*)autoLayoutConstraintsUsingViews:(NSDictionary*)views;
#endif

@end


//TODO : rename style by parentStyle in some APIs

/** TODO
 */
@interface UIView (CKStyle)
@property (nonatomic,copy) NSString* name;

- (NSMutableDictionary*)applyStyle:(NSMutableDictionary*)style;
- (NSMutableDictionary*)applyStyle:(NSMutableDictionary*)style propertyName:(NSString*)propertyName;

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack delegate:(id)delegate;

//private
+ (BOOL)needSubView:(NSMutableDictionary*)style forView:(UIView*)view;

- (UIView*)viewWithKeyPath:(NSString*)keyPath;
- (void)populateViewDictionaryForVisualFormat:(NSMutableDictionary*)dico;

#ifdef __IPHONE_6_0
- (void)setTranslatesAutoresizingMaskIntoConstraints:(BOOL)flag recursive:(BOOL)recursive;
#endif

@end


/** TODO
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


/** TODO
 */
@protocol CKStyleDelegate
@optional

- (CKRoundedCornerViewType)view:(UIView*)view cornerStyleWithStyle:(NSMutableDictionary*)style;
- (CKStyleViewBorderLocation)view:(UIView*)view borderStyleWithStyle:(NSMutableDictionary*)style;
- (CKStyleViewSeparatorLocation)view:(UIView*)view separatorStyleWithStyle:(NSMutableDictionary*)style;
- (UIColor*)separatorColorForView:(UIView*)view withStyle:(NSMutableDictionary*)style;
- (BOOL)object:(id)object shouldReplaceViewWithDescriptor:(CKClassPropertyDescriptor*)descriptor withStyle:(NSMutableDictionary*)style;

@end
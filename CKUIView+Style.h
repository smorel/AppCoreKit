//
//  CKUIView+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-20.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
	CKViewCornerStyleDefault,//in this case, we set the corner style of the parent controller (table plain or grouped)
	//in the following case, we force the corner style of the cell and bypass the parent controller style
	CKViewCornerStyleRounded,
	CKViewCornerStylePlain
}CKViewCornerStyle;

extern NSString* CKStyleColor;
extern NSString* CKStyleGradientColors;
extern NSString* CKStyleGradientLocations;
extern NSString* CKStyleImage;
extern NSString* CKStyleCornerStyle;
extern NSString* CKStyleCornerSize;
extern NSString* CKStyleAlpha;

@interface NSMutableDictionary (CKViewStyle)

- (UIColor*)color;
- (NSArray*)gradientColors;
- (NSArray*)gradientLocations;
- (UIImage*)image;
- (CKViewCornerStyle)cornerStyle;
- (CGSize)cornerSize;
- (CGFloat)alpha;

@end


/* SUPPORTS :
 * CKStyleBackgroundStyle
 */

@interface UIView (CKStyle) 

+ (BOOL)needSubView:(NSMutableDictionary*)style forView:(UIView*)view propertyName:(NSString*)propertyName;

- (void)applyStyle:(NSMutableDictionary*)style;
- (void)applyStyle:(NSMutableDictionary*)style propertyName:(NSString*)propertyName;
- (void)applySubViewsStyle:(NSMutableDictionary*)style appliedStack:(NSMutableSet*)appliedStack;

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack
cornerModifierTarget:(id)target cornerModifierAction:(SEL)action;

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack;

@end

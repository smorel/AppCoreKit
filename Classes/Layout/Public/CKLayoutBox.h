//
//  CKLayoutBox.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKLayoutBoxProtocol.h"


//CKLayoutBox

typedef enum CKLayoutVerticalAlignment{
    CKLayoutVerticalAlignmentTop,
    CKLayoutVerticalAlignmentCenter,
    CKLayoutVerticalAlignmentBottom
}CKLayoutVerticalAlignment;

typedef enum CKLayoutHorizontalAlignment{
    CKLayoutHorizontalAlignmentLeft,
    CKLayoutHorizontalAlignmentCenter,
    CKLayoutHorizontalAlignmentRight
}CKLayoutHorizontalAlignment;


/** CKLayoutBox is the base class for the various layout algorithms.
 @see : CKVerticalBoxLayout, CKHorizontalBoxLayout, CKLayoutFlexibleSpace
 */
@interface CKLayoutBox : NSObject<CKLayoutBoxProtocol>

/** This specify how to align the children layout box vertically in case the height of the current layoutbox is higher that the height of the layouted children boxes.
 
 The possible values are :
 * CKLayoutVerticalAlignmentTop
 * CKLayoutVerticalAlignmentCenter
 * CKLayoutVerticalAlignmentBottom
 
 @info : You can use flexible spaces.
 */
@property(nonatomic,assign) CKLayoutVerticalAlignment verticalAlignment;

/** This specify how to align the children layout box horizontally in case the width of the current layoutbox is higher that the width of the layouted children boxes.
 
 The possible values are :
 * CKLayoutVerticalAlignmentTop
 * CKLayoutVerticalAlignmentCenter
 * CKLayoutVerticalAlignmentBottom
 
 @info : You can use flexible spaces.
 */
@property(nonatomic,assign) CKLayoutHorizontalAlignment horizontalAlignment;

@end

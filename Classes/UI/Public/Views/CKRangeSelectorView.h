//
//  CKRangeSelectorView.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-31.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CKRangeSelectorViewSelector{
    CKRangeSelectorViewSelectorLeft,
    CKRangeSelectorViewSelectorRight
}CKRangeSelectorViewSelector;

typedef enum CKRangeSelectorDisplayType{
    CKRangeSelectorDisplayTypeSingleValue,
    CKRangeSelectorDisplayTypeRange
}CKRangeSelectorDisplayType;

@interface CKRangeSelectorView : UIView

@property(nonatomic,assign) CGFloat minimumValue;
@property(nonatomic,assign) CGFloat maximumValue;
@property(nonatomic,assign) CGFloat increment;
@property(nonatomic,assign) CGFloat startValue;
@property(nonatomic,assign) CGFloat endValue;
@property(nonatomic,assign) CKRangeSelectorDisplayType displayType;

@property(nonatomic,assign) BOOL startSelectionEnabled;
@property(nonatomic,assign) BOOL endSelectionEnabled;

@property(nonatomic,retain,readonly) UIButton* startSelectorButton;
@property(nonatomic,retain,readonly) UIButton* endSelectorButton;
@property(nonatomic,retain,readonly) UIImageView* selectedRangeImageView;
@property(nonatomic,retain,readonly) UIImageView* backgroundImageView;

@property(nonatomic,assign) UIEdgeInsets selectedRangeImageViewEdgeInsets;
@property(nonatomic,assign) UIEdgeInsets backgroundImageViewEdgeInsets;
@property(nonatomic,assign) CGSize selectorButtonSize;


@property(nonatomic,assign) CGFloat labelMargins;
@property(nonatomic,retain,readonly) UILabel* startSelectorLabel;
@property(nonatomic,retain,readonly) UILabel* endSelectorLabel;
@property(nonatomic,retain,readonly) UILabel* joinedStartAndEndSelectorLabel;
@property(nonatomic,retain) NSString* textFormat;
@property(nonatomic,retain) NSString* joinedTextFormat;

@property(nonatomic,copy) void(^willStartEditingBlock)(CKRangeSelectorViewSelector selector);
@property(nonatomic,copy) void(^didEndEditingBlock)();

@end

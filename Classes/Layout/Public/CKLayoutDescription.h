//
//  CKLayoutDescription.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/18/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKArrayCollection.h"

@interface CKLayoutDescription : NSObject
@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain) CKArrayCollection* layoutBoxes;
@property(nonatomic,retain) NSDictionary* viewAttributes;
@end


@interface UIView(CKMultiLayout)
@property(nonatomic,retain) CKArrayCollection* layoutDescriptions;
@property(nonatomic,retain,readonly) CKLayoutDescription* currentLayout;

- (CKLayoutDescription*)layoutDescriptionNamed:(NSString*)name;

- (void)setLayoutNamed:(NSString*)name animated:(BOOL)animated completion:(void(^)())completion;
- (void)setLayout:(CKLayoutDescription*)layoutDescription animated:(BOOL)animated completion:(void(^)())completion;


@end
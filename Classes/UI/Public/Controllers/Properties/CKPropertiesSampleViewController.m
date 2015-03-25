//
//  CKPropertiesSampleViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-12.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertiesSampleViewController.h"
#import "CKPropertyStringViewController.h"
#import "CKPropertyNumberViewController.h"
#import "CKPropertyBoolViewController.h"
#import "CKPropertySelectionViewController.h"
#import "CKPropertyVectorViewController.h"

#import "CKTableViewContentCellController.h"

typedef NS_ENUM(NSInteger, TEST){
    TEST0,
    TEST1
};

@interface CKPropertiesSampleViewController ()
@property(nonatomic,retain) NSString* singleLineString;
@property(nonatomic,retain) NSString* multiLineString;
@property(nonatomic,assign) NSInteger intValue;
@property(nonatomic,assign) CGFloat floatValue;
@property(nonatomic,retain) NSNumber* numberValue;
@property(nonatomic,assign) BOOL boolValue;
@property(nonatomic,assign) TEST enumValue;
@property(nonatomic,assign) CGPoint pointValue;
@property(nonatomic,assign) CGSize sizeValue;
@property(nonatomic,assign) CGRect rectValue;
@property(nonatomic,assign) UIEdgeInsets edgeInsetsValue;
@property(nonatomic,assign) CLLocationCoordinate2D locationCoordinate2DValue;
@property(nonatomic,assign) CGAffineTransform affineTransformValue;

@end

@implementation CKPropertiesSampleViewController

- (void)enumValueExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"TEST", TEST0, TEST1);
}

#pragma mark ViewController Life Cycle

- (void)postInit{
    [super postInit];
    [self setupForm];
}

#pragma mark Initializing Form

- (void)setupForm{
    self.title = @"AppCoreKit - Properties Sample";
    
#define _p(name) [CKProperty propertyWithObject:self keyPath:name]
    
    
    CKPropertyStringViewController* singleLineController = [[[CKPropertyStringViewController alloc]initWithProperty:_p(@"singleLineString")]autorelease];
    CKPropertyStringViewController* multilineLineController = [[[CKPropertyStringViewController alloc]initWithProperty:_p(@"multiLineString")]autorelease];
    multilineLineController.multiline = YES;
    
    CKPropertyNumberViewController* intValueController = [[[CKPropertyNumberViewController alloc]initWithProperty:_p(@"intValue")]autorelease];
    CKPropertyNumberViewController* floatValueController = [[[CKPropertyNumberViewController alloc]initWithProperty:_p(@"floatValue")]autorelease];
    CKPropertyNumberViewController* numberValueController = [[[CKPropertyNumberViewController alloc]initWithProperty:_p(@"numberValue")]autorelease];
    CKPropertyBoolViewController* boolValueController = [[[CKPropertyBoolViewController alloc]initWithProperty:_p(@"boolValue")]autorelease];
    CKPropertySelectionViewController* enumValueController = [[[CKPropertySelectionViewController alloc]initWithProperty:_p(@"enumValue")]autorelease];
    
    CKPropertyVectorViewController* pointValueController = [[[CKPropertyVectorViewController alloc]initWithProperty:_p(@"pointValue")]autorelease];
    CKPropertyVectorViewController* sizeValueController = [[[CKPropertyVectorViewController alloc]initWithProperty:_p(@"sizeValue")]autorelease];
    CKPropertyVectorViewController* rectValueController = [[[CKPropertyVectorViewController alloc]initWithProperty:_p(@"rectValue")]autorelease];
    CKPropertyVectorViewController* edgeInsetsValueController = [[[CKPropertyVectorViewController alloc]initWithProperty:_p(@"edgeInsetsValue")]autorelease];
    CKPropertyVectorViewController* locationCoordinate2DValueController = [[[CKPropertyVectorViewController alloc]initWithProperty:_p(@"locationCoordinate2DValue")]autorelease];
    
    self.affineTransformValue = CGAffineTransformIdentity;
    CKPropertyVectorViewController* affineTransformValueValueController = [[[CKPropertyVectorViewController alloc]initWithProperty:_p(@"affineTransformValue")]autorelease];
    
    NSMutableArray* controllers =[NSMutableArray array];
    [controllers addObjectsFromArray:@[
                                 singleLineController ,
                                 multilineLineController ,
                                 intValueController ,
                                 floatValueController ,
                                 numberValueController ,
                                 boolValueController ,
                                 enumValueController,
                                 pointValueController,
                                 sizeValueController,
                                 rectValueController,
                                 edgeInsetsValueController,
                                 locationCoordinate2DValueController,
                                 affineTransformValueValueController
                                 ]
     ];
    
    CKSection* propertiesSection = [CKSection sectionWithControllers:controllers];
    
    NSArray* sections = @[
        propertiesSection
    ];
    
    [self addSections:sections animated:NO];
  
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self beginBindingsContextByRemovingPreviousBindings];
    [self bindPropertyChangeWithBlock:^(NSString *propertyName, id value) {
        NSLog(@"Did Change Property '%@' = '%@'",propertyName,value);
    }];
    [self endBindingsContext];
}

@end

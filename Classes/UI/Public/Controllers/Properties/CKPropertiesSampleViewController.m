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
#import "CKPropertyEnumViewController.h"

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
    
    NSMutableArray* cells =[NSMutableArray array];
    
    CKPropertyStringViewController* singleLineController = [[[CKPropertyStringViewController alloc]initWithProperty:_p(@"singleLineString")]autorelease];
    CKPropertyStringViewController* multilineLineController = [[[CKPropertyStringViewController alloc]initWithProperty:_p(@"multiLineString")]autorelease];
    multilineLineController.multiline = YES;
    
    CKPropertyNumberViewController* intValueController = [[[CKPropertyNumberViewController alloc]initWithProperty:_p(@"intValue")]autorelease];
    CKPropertyNumberViewController* floatValueController = [[[CKPropertyNumberViewController alloc]initWithProperty:_p(@"floatValue")]autorelease];
    CKPropertyNumberViewController* numberValueController = [[[CKPropertyNumberViewController alloc]initWithProperty:_p(@"numberValue")]autorelease];
    CKPropertyBoolViewController* boolValueController = [[[CKPropertyBoolViewController alloc]initWithProperty:_p(@"boolValue")]autorelease];
    CKPropertyEnumViewController* enumValueController = [[[CKPropertyEnumViewController alloc]initWithProperty:_p(@"enumValue")]autorelease];
    
    
    [cells addObjectsFromArray:@[
                                 [singleLineController newTableViewCellController],
                                 [multilineLineController newTableViewCellController],
                                 [intValueController newTableViewCellController],
                                 [floatValueController newTableViewCellController],
                                 [numberValueController newTableViewCellController],
                                 [boolValueController newTableViewCellController],
                                 [enumValueController newTableViewCellController]
                                 ]
     ];
    
    CKFormSection* propertiesSection = [CKFormSection sectionWithCellControllers:cells];
    
    NSArray* sections = @[
        propertiesSection
    ];
    
    [self addSections:sections];
  
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
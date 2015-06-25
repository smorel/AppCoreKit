//
//  CKPropertyColorViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyColorViewController.h"
#import "CKPropertyVectorViewController.h"
#import "UIColor+Components.h"

@implementation CKPropertyColorViewController

- (void)dealloc{
    [_components release];
    [super dealloc];
}

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super initWithProperty:property readOnly:readOnly];
    self.flags = CKViewControllerFlagsNone;
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if([self isLayoutDefinedInStylesheet])
        return;
    
    UIView* colorView = [[[UIView alloc]init]autorelease];
    colorView.name = @"ColorView";
    colorView.flexibleSize = YES;
    colorView.fixedWidth = 20;
    colorView.marginLeft = 10;
    
    CKHorizontalBoxLayout* hbox = [[[CKHorizontalBoxLayout alloc]init]autorelease];
    
    CKPropertyVectorViewController* controller = [CKPropertyVectorViewController controllerWithProperty:self.property];
    controller.name = @"VectorViewController";
    controller.marginTop = 10;
    
    hbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[controller,colorView]];
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hbox]];
}

- (void)setupBindings{
    UIView* colorView = [self.view viewWithName:@"ColorView"];
    
    CKPropertyVectorViewController* controller = (CKPropertyVectorViewController*)[self.view layoutWithName:@"VectorViewController"];
    controller.propertyNameLabel = self.propertyNameLabel;
    controller.components = self.components;
    controller.readOnly = self.readOnly;
    controller.property = self.property;
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        colorView.backgroundColor = value;
    }];
}

@end


@interface CKColorVector : CKPropertyVector
@property(nonatomic,assign) NSInteger red;
@property(nonatomic,assign) NSInteger green;
@property(nonatomic,assign) NSInteger blue;
@property(nonatomic,assign) NSInteger alpha;
@end

@implementation CKColorVector

- (id)initWithProperty:(CKProperty*)property{
    self = [super initWithProperty:property];
    self.editableProperties = @[ [CKProperty propertyWithObject:self keyPath:@"red"],
                                 [CKProperty propertyWithObject:self keyPath:@"green"],
                                 [CKProperty propertyWithObject:self keyPath:@"blue"],
                                 [CKProperty propertyWithObject:self keyPath:@"alpha"]
                                 ];
    return self;
}

- (void)setRed:(NSInteger)red{
    if(red > 255) red = 255;
    if(red < 0) red = 0;
    UIColor* color = [UIColor colorWithRed:red/255.0f green:[(UIColor*)self.property.value green] blue:[(UIColor*)self.property.value blue] alpha:[(UIColor*)self.property.value alpha]];
    [self.property setValue:color];
}

- (void)setGreen:(NSInteger)green{
    if(green > 255) green = 255;
    if(green < 0) green = 0;
    UIColor* color = [UIColor colorWithRed:[(UIColor*)self.property.value red] green:green/255.0f blue:[(UIColor*)self.property.value blue] alpha:[(UIColor*)self.property.value alpha]];
    [self.property setValue:color];
}

- (void)setBlue:(NSInteger)blue{
    if(blue > 255) blue = 255;
    if(blue < 0) blue = 0;
    UIColor* color = [UIColor colorWithRed:[(UIColor*)self.property.value red] green:[(UIColor*)self.property.value green] blue:blue/255.0f alpha:[(UIColor*)self.property.value alpha]];
    [self.property setValue:color];
}

- (void)setAlpha:(NSInteger)alpha{
    if(alpha > 255) alpha = 255;
    if(alpha < 0) alpha = 0;
    UIColor* color = [UIColor colorWithRed:[(UIColor*)self.property.value red] green:[(UIColor*)self.property.value green] blue:[(UIColor*)self.property.value blue] alpha:alpha/255.0f];
    [self.property setValue:color];
}

- (NSInteger)red{
    return (NSInteger)([(UIColor*)self.property.value red] * 255.0f);
}

- (NSInteger)green{
    return (NSInteger)([(UIColor*)self.property.value green] * 255.0f);
}

- (NSInteger)blue{
    return (NSInteger)([(UIColor*)self.property.value blue] * 255.0f);
}

- (NSInteger)alpha{
    return (NSInteger)([(UIColor*)self.property.value alpha] * 255.0f);
}

@end

//
//  CKPropertyVectorViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyVectorViewController.h"
#import "CKPropertyNumberViewController.h"

@interface CKPropertyVectorViewController()
@property(nonatomic,retain) CKPropertyVector* vector;
@end


@implementation CKPropertyVectorViewController

- (NSString*)reuseIdentifier{
    return [NSString stringWithFormat:@"%@_%@",[super reuseIdentifier],[self.vector class]];
}

+ (Class)vectorClassForProperty:(CKProperty*)property{
    NSString* vectorClassName = nil;
    if(property.descriptor.type){
        vectorClassName = [NSString stringWithFormat:@"CK%@Vector",[[[property.descriptor.type class]description] substringFromIndex:2]];
    }else{
        vectorClassName = [NSString stringWithFormat:@"CK%@Vector",[property.descriptor.className substringFromIndex:2]];
    }
    Class vectorClass = NSClassFromString(vectorClassName);
    
    return vectorClass;
}

+ (BOOL)compatibleWithProperty:(CKProperty*)property{
    return [self vectorClassForProperty:property] != nil;
}

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    Class vectorClass = [CKPropertyVectorViewController vectorClassForProperty:property];
    
    NSAssert(vectorClass, @"Could not find a vector class for representing this property");
    
    CKPropertyVector* vector = nil;
    if(vectorClass){
        vector = [[[vectorClass alloc]initWithProperty:property]autorelease];
    }
    
    return [self initWithPropertyVector:vector readOnly:readOnly];
}

- (instancetype)initWithPropertyVector:(CKPropertyVector*)vector readOnly:(BOOL)readOnly{
    self = [super initWithProperty:vector.property readOnly:readOnly];
    self.vector = vector;
    self.flags = CKViewControllerFlagsNone;
    return self;
}

+ (instancetype)controllerWithPropertyVector:(CKPropertyVector*)vector readOnly:(BOOL)readOnly{
    return [[[[self class]alloc]initWithPropertyVector:vector readOnly:readOnly]autorelease];
}

- (void)dealloc{
    [_vector release];
    [super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    if([self isLayoutDefinedInStylesheet])
        return;
    
    UILabel* PropertyNameLabel = [[[UILabel alloc]init]autorelease];
    PropertyNameLabel.name = @"PropertyNameLabel";
    PropertyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    PropertyNameLabel.textColor = [UIColor blackColor];
    PropertyNameLabel.numberOfLines = 1;
    
    CKVerticalBoxLayout* vbox = [[[CKVerticalBoxLayout alloc]init]autorelease];
    vbox.horizontalAlignment = CKLayoutHorizontalAlignmentLeft;
    vbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel]];
    
    for(CKProperty* editableProperty in self.vector.editableProperties){
        CKPropertyNumberViewController* controller = [CKPropertyNumberViewController controllerWithProperty:editableProperty];
        controller.readOnly = self.readOnly;
        controller.name = editableProperty.name;
        controller.marginTop = 10;
        [vbox addLayoutBox:controller];
    }
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[vbox]];
}

#pragma mark Setup MVC and bindings

- (void)setupBindings{
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    __block CKPropertyVectorViewController* bself = self;
    
    void(^update)() = ^(){
        for(CKProperty* editableProperty in bself.vector.editableProperties){
            CKPropertyNumberViewController* controller = (CKPropertyNumberViewController*)[bself.view layoutWithName:editableProperty.name];
            controller.readOnly = bself.readOnly;
            controller.property = editableProperty;
        }
    };
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        update();
    }];
    
    [self bind:@"readOnly" withBlock:^(id value) {
        update();
    }];
}

@end











@interface CKPointVector : CKPropertyVector
@property(nonatomic,assign) CGFloat x;
@property(nonatomic,assign) CGFloat y;
@end

@implementation CKPointVector

- (id)initWithProperty:(CKProperty*)property{
    self = [super initWithProperty:property];
    self.editableProperties = @[ [CKProperty propertyWithObject:self keyPath:@"x"],
                                 [CKProperty propertyWithObject:self keyPath:@"y"]
                                 ];
    return self;
}

- (void)setX:(CGFloat)x{
    CGPoint p = CGPointMake(x, [self.property.value CGPointValue].y);
    [self.property setValue:[NSValue valueWithCGPoint:p]];
}

- (void)setY:(CGFloat)y{
    CGPoint p = CGPointMake([self.property.value CGPointValue].x, y);
    [self.property setValue:[NSValue valueWithCGPoint:p]];
}

- (CGFloat)x{
    return [self.property.value CGPointValue].x;
}

- (CGFloat)y{
    return [self.property.value CGPointValue].y;
}

@end


@interface CKSizeVector : CKPropertyVector
@property(nonatomic,assign) CGFloat width;
@property(nonatomic,assign) CGFloat height;
@end

@implementation CKSizeVector

- (id)initWithProperty:(CKProperty*)property{
    self = [super initWithProperty:property];
    self.editableProperties = @[ [CKProperty propertyWithObject:self keyPath:@"width"],
                                 [CKProperty propertyWithObject:self keyPath:@"height"]
                                 ];
    return self;
}

- (void)setWidth:(CGFloat)f{
    CGSize p = CGSizeMake(f, [self.property.value CGSizeValue].height);
    [self.property setValue:[NSValue valueWithCGSize:p]];
}

- (void)setHeight:(CGFloat)f{
    CGSize p = CGSizeMake([self.property.value CGSizeValue].width, f);
    [self.property setValue:[NSValue valueWithCGSize:p]];
}

- (CGFloat)width{
    return [self.property.value CGSizeValue].width;
}

- (CGFloat)height{
    return [self.property.value CGSizeValue].height;
}

@end


@interface CKRectVector : CKPropertyVector
@property(nonatomic,assign) CGFloat x;
@property(nonatomic,assign) CGFloat y;
@property(nonatomic,assign) CGFloat width;
@property(nonatomic,assign) CGFloat height;
@end

@implementation CKRectVector

- (id)initWithProperty:(CKProperty*)property{
    self = [super initWithProperty:property];
    self.editableProperties = @[ [CKProperty propertyWithObject:self keyPath:@"x"],
                                 [CKProperty propertyWithObject:self keyPath:@"y"],
                                 [CKProperty propertyWithObject:self keyPath:@"width"],
                                 [CKProperty propertyWithObject:self keyPath:@"height"]
                                 ];
    return self;
}

- (void)setX:(CGFloat)f{
    CGRect p = CGRectMake(f, [self.property.value CGRectValue].origin.y,[self.property.value CGRectValue].size.width,[self.property.value CGRectValue].size.height);
    [self.property setValue:[NSValue valueWithCGRect:p]];
}

- (void)setY:(CGFloat)f{
    CGRect p = CGRectMake([self.property.value CGRectValue].origin.x,f,[self.property.value CGRectValue].size.width,[self.property.value CGRectValue].size.height);
    [self.property setValue:[NSValue valueWithCGRect:p]];
}


- (void)setWidth:(CGFloat)f{
    CGRect p = CGRectMake([self.property.value CGRectValue].origin.x,[self.property.value CGRectValue].origin.y,f,[self.property.value CGRectValue].size.height);
    [self.property setValue:[NSValue valueWithCGRect:p]];
}

- (void)setHeight:(CGFloat)f{
    CGRect p = CGRectMake([self.property.value CGRectValue].origin.x,[self.property.value CGRectValue].origin.y,[self.property.value CGRectValue].size.width,f);
    [self.property setValue:[NSValue valueWithCGRect:p]];
}

- (CGFloat)x{
    return [self.property.value CGRectValue].origin.x;
}

- (CGFloat)y{
    return [self.property.value CGRectValue].origin.y;
}

- (CGFloat)width{
    return [self.property.value CGRectValue].size.width;
}

- (CGFloat)height{
    return [self.property.value CGRectValue].size.height;
}

@end


@interface CKEdgeInsetsVector : CKPropertyVector
@property(nonatomic,assign) CGFloat top;
@property(nonatomic,assign) CGFloat left;
@property(nonatomic,assign) CGFloat bottom;
@property(nonatomic,assign) CGFloat right;
@end

@implementation CKEdgeInsetsVector

- (id)initWithProperty:(CKProperty*)property{
    self = [super initWithProperty:property];
    self.editableProperties = @[ [CKProperty propertyWithObject:self keyPath:@"top"],
                                 [CKProperty propertyWithObject:self keyPath:@"left"],
                                 [CKProperty propertyWithObject:self keyPath:@"bottom"],
                                 [CKProperty propertyWithObject:self keyPath:@"right"]
                                 ];
    return self;
}

- (void)setTop:(CGFloat)f{
    UIEdgeInsets p = UIEdgeInsetsMake(f, [self.property.value UIEdgeInsetsValue].left,[self.property.value UIEdgeInsetsValue].bottom,[self.property.value UIEdgeInsetsValue].right);
    [self.property setValue:[NSValue valueWithUIEdgeInsets:p]];
}

- (void)setLeft:(CGFloat)f{
    UIEdgeInsets p = UIEdgeInsetsMake([self.property.value UIEdgeInsetsValue].top,f,[self.property.value UIEdgeInsetsValue].bottom,[self.property.value UIEdgeInsetsValue].right);
    [self.property setValue:[NSValue valueWithUIEdgeInsets:p]];
}


- (void)setBottom:(CGFloat)f{
    UIEdgeInsets p = UIEdgeInsetsMake([self.property.value UIEdgeInsetsValue].top,[self.property.value UIEdgeInsetsValue].left,f,[self.property.value UIEdgeInsetsValue].right);
    [self.property setValue:[NSValue valueWithUIEdgeInsets:p]];
}

- (void)setRight:(CGFloat)f{
    UIEdgeInsets p = UIEdgeInsetsMake([self.property.value UIEdgeInsetsValue].top,[self.property.value UIEdgeInsetsValue].left,[self.property.value UIEdgeInsetsValue].bottom,f);
    [self.property setValue:[NSValue valueWithUIEdgeInsets:p]];
}

- (CGFloat)top{
    return [self.property.value UIEdgeInsetsValue].top;
}

- (CGFloat)left{
    return [self.property.value UIEdgeInsetsValue].left;
}

- (CGFloat)bottom{
    return [self.property.value UIEdgeInsetsValue].bottom;
}

- (CGFloat)right{
    return [self.property.value UIEdgeInsetsValue].right;
}

@end



@interface CKLocationCoordinate2DVector : CKPropertyVector
@property(nonatomic,assign) CGFloat latitude;
@property(nonatomic,assign) CGFloat longitude;
@end

@implementation CKLocationCoordinate2DVector

- (id)initWithProperty:(CKProperty*)property{
    self = [super initWithProperty:property];
    self.editableProperties = @[ [CKProperty propertyWithObject:self keyPath:@"latitude"],
                                 [CKProperty propertyWithObject:self keyPath:@"longitude"]
                                 ];
    return self;
}

- (void)setLatitude:(CGFloat)f{
    CLLocationCoordinate2D p = CLLocationCoordinate2DMake(f, [self.property.value MKCoordinateValue].longitude);
    [self.property setValue:[NSValue valueWithMKCoordinate:p]];
}

- (void)setLongitude:(CGFloat)f{
    CLLocationCoordinate2D p = CLLocationCoordinate2DMake([self.property.value MKCoordinateValue].latitude, f);
    [self.property setValue:[NSValue valueWithMKCoordinate:p]];
}

- (CGFloat)latitude{
    return [self.property.value MKCoordinateValue].latitude;
}

- (CGFloat)longitude{
    return [self.property.value MKCoordinateValue].longitude;
}

@end



@interface CKAffineTransformVector : CKPropertyVector
@property(nonatomic,assign)CGFloat x;
@property(nonatomic,assign)CGFloat y;
@property(nonatomic,assign)CGFloat angle;
@property(nonatomic,assign)CGFloat scaleX;
@property(nonatomic,assign)CGFloat scaleY;
@end

@implementation CKAffineTransformVector

- (id)initWithProperty:(CKProperty*)property{
    self = [super initWithProperty:property];
    self.editableProperties = @[ [CKProperty propertyWithObject:self keyPath:@"x"],
                                 [CKProperty propertyWithObject:self keyPath:@"y"],
                                 [CKProperty propertyWithObject:self keyPath:@"angle"],
                                 [CKProperty propertyWithObject:self keyPath:@"scaleX"],
                                 [CKProperty propertyWithObject:self keyPath:@"scaleY"]
                                 ];
    return self;
}

- (CGAffineTransform)transformWithX:(CGFloat)x y:(CGFloat)y angle:(CGFloat)angle scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, scaleX,scaleY);
    transform = CGAffineTransformRotate(transform, angle * M_PI / 180.0 );
    transform = CGAffineTransformTranslate(transform, x, y);
    return transform;
}

- (void)setX:(CGFloat)x{
    CGAffineTransform transform = [self transformWithX:x y:self.y angle:self.angle scaleX:self.scaleX scaleY:self.scaleY];
    [self.property setValue:[NSValue valueWithCGAffineTransform:transform]];
}

- (void)setY:(CGFloat)y{
    CGAffineTransform transform = [self transformWithX:self.x y:y angle:self.angle scaleX:self.scaleX scaleY:self.scaleY];
    [self.property setValue:[NSValue valueWithCGAffineTransform:transform]];
}

- (void)setAngle:(CGFloat)angle{
    CGAffineTransform transform = [self transformWithX:self.x y:self.y angle:angle scaleX:self.scaleX scaleY:self.scaleY];
    [self.property setValue:[NSValue valueWithCGAffineTransform:transform]];
}

- (void)setScaleX:(CGFloat)scaleX{
    CGAffineTransform transform = [self transformWithX:self.x y:self.y angle:self.angle scaleX:scaleX scaleY:self.scaleY];
    [self.property setValue:[NSValue valueWithCGAffineTransform:transform]];
}

- (void)setScaleY:(CGFloat)scaleY{
    CGAffineTransform transform = [self transformWithX:self.x y:self.y angle:self.angle scaleX:self.scaleX scaleY:scaleY];
    [self.property setValue:[NSValue valueWithCGAffineTransform:transform]];
}

- (CGFloat)x{
    return CKCGAffineTransformGetTranslateX([self.property.value CGAffineTransformValue]);
}

- (CGFloat)y{
    return CKCGAffineTransformGetTranslateY([self.property.value CGAffineTransformValue]);
}

- (CGFloat)angle{
    return CKCGAffineTransformGetRotation([self.property.value CGAffineTransformValue]) * 180 / M_PI;
}

- (CGFloat)scaleX{
    return CKCGAffineTransformGetScaleX([self.property.value CGAffineTransformValue]);
}

- (CGFloat)scaleY{
    return CKCGAffineTransformGetScaleY([self.property.value CGAffineTransformValue]);
}

@end


@implementation CKPropertyVector

- (void)dealloc{
    [_property release];
    [_editableProperties release];
    [super dealloc];
}

- (id)initWithProperty:(CKProperty*)property{
    self = [super init];
    self.property = property;
    return self;
}

+ (CKPropertyVector*)vectorForPointProperty:(CKProperty*)property{
    return [[[CKPointVector alloc]initWithProperty:property]autorelease];
}

+ (CKPropertyVector*)vectorForSizeProperty:(CKProperty*)property{
    return [[[CKSizeVector alloc]initWithProperty:property]autorelease];
}

+ (CKPropertyVector*)vectorForRectProperty:(CKProperty*)property{
    return [[[CKRectVector alloc]initWithProperty:property]autorelease];
}

+ (CKPropertyVector*)vectorForEdgeInsetsProperty:(CKProperty*)property{
    return [[[CKEdgeInsetsVector alloc]initWithProperty:property]autorelease];
}

+ (CKPropertyVector*)vectorForLocationCoordinate2DProperty:(CKProperty*)property{
    return [[[CKLocationCoordinate2DVector alloc]initWithProperty:property]autorelease];
}

+ (CKPropertyVector*)vectorForAffineTransformProperty:(CKProperty*)property{
    return [[[CKAffineTransformVector alloc]initWithProperty:property]autorelease];
}

@end

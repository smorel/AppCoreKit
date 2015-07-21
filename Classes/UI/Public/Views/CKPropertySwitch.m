//
//  CKPropertySwitch.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-07-21.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertySwitch.h"
#import "CKLocalization.h"
#import "CKBinding.h"
#import "NSValueTransformer+Additions.h"

@implementation CKPropertySwitch

- (instancetype)init{
    self = [super init];
    [self postInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self postInit];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self postInit];
    return self;
}

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    self = [super init];
    
    self.readOnly = readOnly;
    self.property = property;
    
    return self;
}

- (void)setProperty:(CKProperty *)property{
    [_property release];
    _property = [property retain];
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    
    __block CKPropertySwitch* bself = self;
    
    
    [self beginBindingsContextWithScope:@"CKPropertySwitch"];
    
    [self bind:@"readOnly" executeBlockImmediatly:YES withBlock:^(id value) {
        self.userInteractionEnabled = !bself.readOnly;
    }];
    
    [self bindEvent:UIControlEventValueChanged withBlock:^{
        [bself.property setValue:@(bself.on)];
    }];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        BOOL bo = [value boolValue];
        if(bself.on != bo){
            bself.on = bo;
        }
    }];
    
    [self endBindingsContext];
}

- (void)dealloc{
    [self clearBindingsContextWithScope:@"CKPropertySwitch"];
    
    [_property release];
    [super dealloc];
}

- (void)postInit{
}

@end

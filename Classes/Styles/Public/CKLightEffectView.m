//
//  CKLightEffectView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-01.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKLightEffectView.h"
#import "NSObject+Bindings.h"

@interface CKEffectView()
@property(nonatomic,assign)CGRect lastFrameInWindow;
@end

@implementation CKLightEffectView

- (void)dealloc{
    [self clearBindingsContextWithScope:@"CKLightEffectView"];
    [super dealloc];
}

- (void)didRegisterForUpdates{
    __block CKLightEffectView* bself = self;
    
    [self beginBindingsContextWithScope:@"CKLightEffectView"];
    [NSNotificationCenter bindNotificationName:CKLightDidChangeNotification withBlock:^(NSNotification *notification) {
        [bself setNeedsEffectUpdate];
    }];
    [self endBindingsContext];
}

- (void)didUnregisterForUpdates{
    [self clearBindingsContextWithScope:@"CKLightEffectView"];
}

- (CKLight*)light{
    return [CKLight sharedInstance];
}

@end

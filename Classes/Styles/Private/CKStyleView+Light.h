//
//  CKStyleView+Light.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView.h"
#import "CKSharedDisplayLink.h"
#import "CKLight.h"

@interface CKStyleView (Light)<CKSharedDisplayLinkDelegate>

- (void)updateLights;

@end

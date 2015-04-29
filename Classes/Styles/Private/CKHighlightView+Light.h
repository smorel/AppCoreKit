//
//  CKStyleView+Light.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKHighlightView.h"
#import "CKSharedDisplayLink.h"

@interface CKHighlightView (Light)<CKSharedDisplayLinkDelegate>

- (void)updateLights;

@end

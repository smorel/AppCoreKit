//
//  CKLightEffectView.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-01.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKEffectView.h"
#import "CKLight.h"

/**
 */
@interface CKLightEffectView : CKEffectView

/** An accessor on the CKLight shared instance.
 */
@property(nonatomic,readonly) CKLight* light;

@end
